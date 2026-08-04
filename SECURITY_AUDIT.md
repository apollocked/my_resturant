# Security Audit & Hardening Report — my_resturant

Date: 2026-08-04
Scope: Flutter app (`lib/`) + Supabase schema (`supabase/migration.sql`, live project `wwzvywkvblftreqdusay`)
Method: 4 parallel read-only code audits + live-database inspection + targeted fixes.

Status legend:
- **[FIXED]** — remediated in this pass
- **[PARTIAL]** — mitigated (defense in depth) but a design decision remains
- **[REMAINS]** — not addressed, needs product/UX decision or external action

---

## 1. CRITICAL — fixed

### 1.1 Role escalation + activation bypass (profiles RLS)
`profiles` had `FOR ALL` RLS on own row (`migration.sql:16`). Any authenticated user could
`UPDATE profiles SET role='admin', activated=TRUE WHERE id=auth.uid()` and bypass the entire
PIN/activation gate.

**[FIXED]**
- Profiles are now SELECT-only via the Data API. All writes go through SECURITY DEFINER RPCs:
  `save_passcodes()`, `change_passcode()`, `set_role()`, `verify_pin()`, `claim_promo_code()`.
- PIN hash columns are unreadable client-side:
  `REVOKE SELECT (pin_waiter, pin_kitchen, pin_admin) ON profiles FROM anon, authenticated;`
- App updated (`supabase_auth_repo.dart`) to call the RPCs instead of direct upserts.

### 1.2 Promo-code theft (promo_codes RLS)
`SELECT USING(true)`, `INSERT WITH CHECK(true)`, `DELETE USING(used_by IS NULL)` meant any
authenticated user could read every code, mint their own, or delete others'.

**[FIXED]**
- New server-side `is_admin()` helper (checks `auth.users.email` — unique, so the admin's
  email cannot be adopted). SELECT/INSERT/DELETE policies now require `is_admin()`.
- `expires_at` and `created_by` columns added to the schema (the app was already writing
  `expires_at` that was missing from `migration.sql` — schema drift fixed).

### 1.3 Non-atomic claim / TOCTOU / expiry
`claim_promo_code()` did SELECT-then-UPDATE (race: two users could both claim), ignored
expiry, had no rate limit, and its function had no `search_path` guard.

**[FIXED]**
- Single atomic `UPDATE ... WHERE used_by IS NULL AND (expires_at IS NULL OR expires_at > NOW())`
  with `GET DIAGNOSTICS ROW_COUNT` — no race.
- Rejects expired codes; an account can only be activated once.
- `SET search_path = public` added to all SECURITY DEFINER functions.

### 1.4 No role-based write RLS
All write policies checked only `restaurant_id = auth.uid()`, never role.

**[PARTIAL]** — See §4.1. The app treats waiter/kitchen/admin as UI modes of a single
restaurant account; enforcing role-based writes requires a multi-account staff model.

---

## 2. HIGH — fixed / mitigated

### 2.1 PINs: unsalted client-side SHA-256, no rate limit
**[FIXED]** PINs are now hashed **server-side with bcrypt** (`pgcrypto` `crypt/gen_salt('bf')`)
inside `save_passcodes()`/`change_passcode()`, and verified in `verify_pin()`.
`verify_pin()` is **rate-limited**: max 5 failed attempts per 5 minutes per user
(`pin_attempts` table, not exposed to clients).
App no longer computes hashes (removed `crypto` usage); client sends the raw PIN to the RPC.
All PIN input fields enforce digits-only (`FilteringTextInputFormatter.digitsOnly`).

**Migration caveat:** old unsalted hashes cannot be verified by bcrypt. The migration clears
all PINs; each owner re-sets them from the setup screen. `RoleCubit` now always asks the
server (`passcodes_configured()`), so the stale local cache cannot suppress the setup page.

### 2.2 Role session restored from tamperable prefs
`RoleCubit.load()` replayed `role_name`/`role_logged_in` from SharedPreferences without a
server check, so editing prefs granted admin UI.

**[FIXED]** The last-used role is now restored from the **server** (`profiles.role`, written
only via the `set_role()` RPC), never from local prefs — so a tampered cache cannot grant a
role. Cold start returns to the last role without a PIN; PINs still gate switching into admin
from a non-admin role. (An earlier iteration required a PIN on every cold start; that was
reverted for UX since the server-side restore already closes the tampering hole.)

### 2.3 Hardcoded dev-email admin gate
`/promo-codes` gated by `acct.email == 'hamabarznji1990@gmail.com'` in the router; the account
cubit optimistically updates `state.email`.

**[PARTIAL]** Client gate kept as UX, but the server now enforces `is_admin()` on every
promo-code operation, so the client check is no longer a security boundary. (A user cannot
adopt the admin email — Supabase enforces email uniqueness, and a fresh email changes the
JWT claim away from admin.)

### 2.4 Release builds signed with debug keystore
`android/app/build.gradle.kts` uses the debug signing config for release.

**[REMAINS]** Generate a proper release keystore and configure `key.properties`.

### 2.5 Supabase anon key + URL in public git history
`lib/core/config/supabase_credentials.dart` existed in commits `41c7ad2` / `c958203`;
repo is public (`github.com/apollocked/my_resturant`).

**[REMAINS]** Rotate the anon key in the Supabase dashboard and purge history
(`git filter-repo` / BFG), then force-push. RLS limits blast radius but the key should
still be rotated.

### 2.6 Dead `LocalAuthRepository` stored the password in plaintext
`auth_repository_impl.dart` stored the account password verbatim in SharedPreferences
(under the misleading key `account_password_hash`).

**[FIXED]** File deleted. Also deleted the two orphaned duplicate auth pages
(`account_login_page.dart`, `create_account_page.dart`) — the router only uses
`account_auth_page.dart`.

---

## 3. MEDIUM — fixed / remains

### 3.1 id-only queries lacked tenant filter (defense in depth)
`editRecipe`, `removeRecipe`, `toggleRecipe`, `changeOrderStatus` filtered by `id` only.
**[FIXED]** All now also `.eq('restaurant_id', uid)` (RLS already enforced this; belt and braces).

### 3.2 `_mapOrder` unguarded `jsonDecode`
One corrupt `items_json` row could kill the kitchen/orders realtime stream.
**[FIXED]** Decode wrapped in try/catch → falls back to empty items and logs.

### 3.3 Unbounded notes / description / name fields
Order notes, per-item notes, recipe name/description had no length caps.
**[FIXED]**
- UI: `maxLength` on order notes (200), item notes (120), dish name (80), description (1000), category name (32).
- Server: CHECK constraints (name ≤ 80, description ≤ 1000, order notes ≤ 1000) with `NOT VALID` in the live-DB delta so existing rows can't block the migration.

### 3.4 Category keys unsanitized; reserved `all`; 15-category cap skipped
**[FIXED]**
- `category_form_page.dart`: key must match `^[a-z0-9_]{1,32}$` and not be `all`; friendly error in EN/AR/KU.
- `addCategory` now enforces `maxCategoriesPerRestaurant` (15) client-side (server trigger already existed).

### 3.5 Predictable `tracking_code`
`ORD-<epochMillis>` was guessable/colliding.
**[FIXED]** Appended a secure random 4-digit suffix.

### 3.6 Dish-image: picsum seed leaked the dish name; 2MB check bypassed
`dish_form_page` defaulted missing images to `https://picsum.photos/seed/<dish-name>/400/300`
(sent dish names to a third party) and the upload path lacked a size check.
**[FIXED]**
- No image → empty URL (AppImage renders a restaurant placeholder).
- `_uploadImage` now enforces `AppConstants.maxImageSizeBytes` (2MB) post-compression.
- `uploadImage` already enforced it (kept).

### 3.7 `profiles` in realtime publication
Streaming `profiles` exposed emails and hashes to subscribers.
**[FIXED]** Removed `profiles` from `supabase_realtime` in `migration.sql` and in the delta.

### 3.8 `saveOrder` full-table `count()` scan per insert; no pagination
10K-cap counts scan the whole table on every order.
**[REMAINS]** Acceptable at free-tier volume; revisit with an archived-orders table if orders grow.

### 3.9 Re-PIN on cold start for admin
**[FIXED]** Covered by §2.2.

### 3.10 All roles see full order data / revenue
Kitchen/waiter/admin can all view revenue reports.
**[REMAINS]** Requires a staff/roles product model (see §4.1).

---

## 4. Design notes (decisions needed)

### 4.1 Role-based data access
Today roles are only UI modes of the owner's single account; all staff share the owner's
session. Restaurant data is isolated per account (`restaurant_id = uid`), which is correct.
True role separation (waiter can't delete recipes) needs sub-accounts — a product decision.

### 4.2 `updateEmail` optimistic state
Account email is cached optimistically; with server-enforced `is_admin()` this is no longer
exploitable. Optional cleanup: re-read email from the server after `updateUser`.

---

## 5. CLEAN — verified during audit
- No service-role/secret keys in the repo or git history.
- `.env` is git-ignored (SUPABASE_URL, SUPABASE_ANON_KEY, WEB_CLIENT_ID only).
- No SQL injection (parameterized queries); no backdoor PINs/hardcoded passwords.
- Storage bucket RLS isolates each restaurant's images by path prefix.
- Tenant RLS correct on recipes/orders/categories/app_settings.
- Google ID-token flow validated server-side by Supabase.

---

## 6. How to apply the fixes — DONE

1. ✅ **SQL applied to the live project `wwzvywkvblftreqdusay`** via the Supabase MCP
   on 2026-08-04 (`security_hardening` + `restrict_rpc_execute` migrations + a
   `cleanup_old_orders` search_path fix). The full delta is `supabase/security_hardening.sql`.
   - All 8 RPCs verified present: `save_passcodes`, `change_passcode`, `verify_pin`,
     `passcodes_configured`, `set_role`, `is_admin`, `claim_promo_code`, `is_activated`.
   - PostgREST schema reloaded (`NOTIFY pgrst, 'reload schema'`).
   - ⚠️ Every account's PINs were cleared — owners must re-enter passcodes on the setup
     screen on next app start.
2. Client EXECUTE locked down: `anon` can no longer execute any SECURITY DEFINER function;
   the 8 auth RPCs are granted to `authenticated` only. `cleanup_old_orders`,
   `auto_confirm_user`, `rls_auto_enable`, and the limit-check triggers are fully revoked
   from client roles (cron/triggers run as the owner and are unaffected).
3. **Manual follow-ups** (see §2.4, §2.5): release keystore, rotate anon key, purge git history.
   Also recommend enabling Auth → "Leaked password protection" in the dashboard.

## 7. Files changed
- `supabase/migration.sql` — hardened profiles/promo RLS, RPCs, realtime, constraints
- `supabase/security_hardening.sql` — apply-to-live delta (idempotent), incl. RPC EXECUTE lockdown + search_path on trigger fns
- `lib/data/repositories/supabase_auth_repo.dart` — RPC calls, removed client hashing
- `lib/data/repositories/supabase_data_repo.dart` — tenant filters, jsonDecode guard, category cap, tracking code
- `lib/presentation/cubits/role_cubit.dart` — server-trusted config, no prefs role restore
- `lib/presentation/pages/admin/category_form_page.dart` — key validation
- `lib/presentation/pages/admin/dish_form_page.dart` — no picsum, 2MB check
- `lib/presentation/pages/admin/change_passcodes_page.dart` — digits-only PIN
- `lib/presentation/pages/setup/setup_page.dart` — digits-only PIN
- `lib/presentation/widgets/admin/dish_form_fields.dart` — name/description caps
- `lib/presentation/widgets/order/cart_bottom_bar.dart`, `cart_item_card.dart` — note caps
- `lib/core/l10n/messages_{en,ar,ku}.dart` — new `invalid_category` string
- DELETED: `lib/data/repositories/auth_repository_impl.dart`,
  `lib/presentation/pages/auth/account_login_page.dart`,
  `lib/presentation/pages/auth/create_account_page.dart`

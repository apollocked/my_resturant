import { createClient } from "jsr:@supabase/supabase-js@2";

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

function base64Url(s: string): string {
  return btoa(s).replace(/=+$/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const body = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const bin = atob(body);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes.buffer;
}

async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claim = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${base64Url(JSON.stringify(header))}.${base64Url(JSON.stringify(claim))}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned)),
  );
  let bin = "";
  for (const b of sig) bin += String.fromCharCode(b);
  const jwt = `${unsigned}.${base64Url(bin)}`;
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) throw new Error(`OAuth token failed: ${res.status} ${await res.text()}`);
  const data = await res.json();
  if (!data.access_token) throw new Error("No access_token in OAuth response");
  return data.access_token;
}

const TEXTS: Record<string, { title: string; body: string }> = {
  en: {
    title: "Security alert",
    body: "Someone entered the role PIN wrong 3 times in a row.",
  },
  ar: {
    title: "تنبيه أمني",
    body: "قام شخص بإدخال رمز الدور بشكل خاطئ 3 مرات متتالية.",
  },
  ku: {
    title: "ئاگادارکردنەوەی ئاسایش",
    body: "کەسێک کێسکۆدی ڕۆڵی ٣ جار لەسەریەک هەڵەی کرد.",
  },
};

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response("Unauthorized", { status: 401 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );
  const {
    data: { user },
    error: userErr,
  } = await supabase.auth.getUser();
  if (userErr || !user) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { data: tokens, error: tokensErr } = await supabase
    .from("device_tokens")
    .select("token")
    .eq("user_id", user.id);
  if (tokensErr) return new Response(tokensErr.message, { status: 500 });
  if (!tokens || tokens.length === 0) {
    return new Response("no tokens", { status: 200 });
  }

  const body = await req.json().catch(() => ({}));
  const locale =
    typeof body.locale === "string" && ["en", "ar", "ku"].includes(body.locale)
      ? body.locale
      : "en";
  const text = TEXTS[locale];

  const saRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!saRaw) {
    return new Response("FIREBASE_SERVICE_ACCOUNT secret not set", { status: 500 });
  }
  let sa: ServiceAccount;
  try {
    sa = JSON.parse(saRaw) as ServiceAccount;
    const accessToken = await getAccessToken(sa);
    const codes = await Promise.all(
      tokens.map(async (t) => {
        const res = await fetch(
          `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              message: {
                token: t.token,
                notification: { title: text.title, body: text.body },
                data: { type: "security_alert" },
                android: {
                  priority: "HIGH",
                  notification: {
                    channel_id: "manager_channel",
                    icon: "@mipmap/ic_launcher",
                  },
                },
              },
            }),
          },
        );
        return res.status;
      }),
    );
    return new Response(JSON.stringify({ sent: codes.length, codes }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (e) {
    return new Response(e instanceof Error ? e.message : "send failed", {
      status: 500,
    });
  }
});

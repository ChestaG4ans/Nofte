/**
 * NOFTe API - Cloudflare Worker
 * Uses Groq API for AI chat
 */

export default {
  async fetch(request, env, ctx) {
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    };

    // Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);

    // Health check endpoint
    if (url.pathname === "/api/health") {
      return new Response(JSON.stringify({
        status: "ok",
        timestamp: new Date().toISOString(),
        service: "NOFTe API (Cloudflare Worker)"
      }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      });
    }

    // Chat endpoint
    if (url.pathname === "/api/chat" && request.method === "POST") {
      try {
        const { message } = await request.json();

        if (!message) {
          return new Response(JSON.stringify({ error: "Pesan kosong" }), {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" }
          });
        }

        // Call Groq API
        const groqResponse = await fetch("https://api.groq.com/openai/v1/chat/completions", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${env.GROQ_API_KEY}`,
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            model: "llama-3.1-8b-instant",
            messages: [
              {
                role: "system",
                content: "Kamu adalah asisten dapur pintar bernama NOFTe. Kamu membantu pengguna mengelola bahan makanan, memberikan saran resep, dan tips memasak. Selalu jawab dalam Bahasa Indonesia yang sopan dan ramah."
              },
              {
                role: "user",
                content: message
              }
            ],
            max_tokens: 500,
            temperature: 0.7,
          })
        });

        if (!groqResponse.ok) {
          const error = await groqResponse.text();
          console.error("Groq API Error:", error);
          return new Response(JSON.stringify({ error: "AI service error" }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" }
          });
        }

        const data = await groqResponse.json();
        const reply = data.choices[0].message.content;

        return new Response(JSON.stringify({ reply }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });

      } catch (err) {
        console.error("Worker Error:", err);
        return new Response(JSON.stringify({ error: err.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    }

    // Not found
    return new Response(JSON.stringify({ error: "Not found" }), {
      status: 404,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  }
};

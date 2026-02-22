require("dotenv").config();

/**
 * Option A - Failure Explainer
 *
 * I chose this over Flaky Test Classifier because
 * real-time failure explanation reduces debugging
 * effort immediately and improves CI feedback loops.
 * This integrates AI directly into the test lifecycle.
 */

async function explainFailure(data) {
  try {
    if (!process.env.GEMINI_API_KEY) {
      return "AI analysis skipped: GEMINI_API_KEY not found.";
    }

    const prompt = `
        You are a Senior SDET reviewing a failed Cypress BDD test.

        Test Name: ${data.title}
        Error Message: ${data.error}

        Analyze:
        1. What likely broke?
        2. Root cause?
        3. Suggested fix?
        4. Is this a real bug, flaky test, or test issue?

        Respond clearly and structured.
    `;

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [{ text: prompt }],
            },
          ],
        }),
      }
    );

    let result;
    try {
      result = await response.json();
    } catch (e) {
      return `AI analysis failed: Could not parse Gemini response`;
    }

    if (!response.ok) {
      console.error("Gemini API Error:", result);
      return `AI analysis failed: ${JSON.stringify(result)}`;
    }

    return (
      result?.candidates?.[0]?.content?.parts
        ?.map((p) => p.text)
        .join("\n") || "No AI response received."
    );
  } catch (error) {
    console.error("Gemini API Error:", error.message);
    return `AI analysis failed: ${error.message}`;
  }
}

module.exports = { explainFailure };
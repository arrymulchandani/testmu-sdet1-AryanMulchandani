const { defineConfig } = require("cypress");
const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
const {
  addCucumberPreprocessorPlugin,
} = require("@badeball/cypress-cucumber-preprocessor");
const {
  createEsbuildPlugin,
} = require("@badeball/cypress-cucumber-preprocessor/esbuild");

module.exports = defineConfig({
  env: {
      stepDefinitions: "cypress/e2e/stepDefinitions/**/*.js",
  },

  e2e: {
    specPattern: "cypress/e2e/features/**/*.feature",

    async setupNodeEvents(on, config) {
      await addCucumberPreprocessorPlugin(on, config);

      on(
        "file:preprocessor",
        createBundler({
          plugins: [createEsbuildPlugin(config)],
        })
      );

      // LLM Failure Task
      const { explainFailure } = require("./cypress/support/llmFailureHandler");
      const fs = require("fs");

      on("task", {
        async analyzeFailure(data) {
          try {
            const aiResponse = await explainFailure(data);

            const reportPath = "cypress/reports/ai-failure-report.json";

            let existing = [];
            if (fs.existsSync(reportPath)) {
              existing = JSON.parse(
                fs.readFileSync(reportPath, "utf-8")
              );
            }

            existing.push({
              test: data.title,
              error: data.error,
              aiAnalysis: aiResponse,
              timestamp: new Date().toISOString(),
            });

            fs.writeFileSync(
              reportPath,
              JSON.stringify(existing, null, 2)
            );

            return null;
          } catch (err) {
            console.error("AI analysis failed:", err.message);
            return null;
          }
        },
      });

      return config;
    },
  },
});
import js from "@eslint/js";
import tsparser from "@typescript-eslint/parser";
import tsplugin from "@typescript-eslint/eslint-plugin";

export default [
  {
    files: ["src/**/*.ts"],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        projectService: true,
      },
    },
    plugins: {
      "@typescript-eslint": tsplugin,
      import: require("eslint-plugin-import"),
    },
    rules: {
      ...js.configs.recommended.rules,
      "@typescript-eslint/no-explicit-any": "error",
      "import/order": [
        "warn",
        {
          "alphabetize": { "order": "asc", "caseInsensitive": true },
          "newlines-between": "always",
        },
      ],
    },
  },
];

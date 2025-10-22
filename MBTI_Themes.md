# MBTI Theme Map (Flat Colors Only)

This document maps each personality type to its background color (as CSS var and RGB) and font color. Gradients have been removed.

```json
{
  "applies_via": {
    "css_vars": ["--mbti-bg-pattern", "--mbti-text-primary"],
    "modes": ["personality", "mint"],
    "gender_overrides": ["female", "male"]
  },
  "mint_mode": {
    "bg": { "var": "var(--color-mint-500)", "rgb": "rgb(130, 237, 166)" },
    "font": "var(--color-green-900)"
  },
  "types": {
    "INTJ": {
      "default": { "bg": { "var": "var(--color-purple-400)", "rgb": "rgb(200, 140, 253)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-analyst-fem-primary)", "rgb": "rgb(221, 214, 254)" }, "font": "rgb(91, 33, 182)" },
      "male": { "bg": { "var": "var(--color-analyst-masc-primary)", "rgb": "rgb(245, 240, 255)" }, "font": "rgb(76, 29, 149)" }
    },
    "INTP": {
      "default": { "bg": { "var": "var(--color-cyan-200)", "rgb": "rgb(174, 251, 255)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-analyst-fem-primary)", "rgb": "rgb(221, 214, 254)" }, "font": "rgb(91, 33, 182)" },
      "male": { "bg": { "var": "var(--color-analyst-masc-primary)", "rgb": "rgb(245, 240, 255)" }, "font": "rgb(76, 29, 149)" }
    },
    "ENTJ": {
      "default": { "bg": { "var": "var(--color-orange-500)", "rgb": "rgb(255, 145, 36)" }, "font": "var(--color-cream)" },
      "female": { "bg": { "var": "var(--color-analyst-fem-primary)", "rgb": "rgb(221, 214, 254)" }, "font": "rgb(91, 33, 182)" },
      "male": { "bg": { "var": "var(--color-analyst-masc-primary)", "rgb": "rgb(245, 240, 255)" }, "font": "rgb(76, 29, 149)" }
    },
    "ENTP": {
      "default": { "bg": { "var": "var(--color-pink-500)", "rgb": "rgb(252, 86, 129)" }, "font": "var(--color-cream)" },
      "female": { "bg": { "var": "var(--color-analyst-fem-primary)", "rgb": "rgb(221, 214, 254)" }, "font": "rgb(91, 33, 182)" },
      "male": { "bg": { "var": "var(--color-analyst-masc-primary)", "rgb": "rgb(245, 240, 255)" }, "font": "rgb(76, 29, 149)" }
    },
    "INFJ": {
      "default": { "bg": { "var": "var(--color-lilac-300)", "rgb": "rgb(246, 187, 253)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-diplomat-fem-primary)", "rgb": "rgb(187, 247, 208)" }, "font": "rgb(154, 52, 18)" },
      "male": { "bg": { "var": "var(--color-diplomat-masc-primary)", "rgb": "rgb(240, 255, 245)" }, "font": "rgb(154, 52, 18)" }
    },
    "INFP": {
      "default": { "bg": { "var": "var(--color-lilac-300)", "rgb": "rgb(246, 187, 253)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-diplomat-fem-primary)", "rgb": "rgb(187, 247, 208)" }, "font": "rgb(154, 52, 18)" },
      "male": { "bg": { "var": "var(--color-diplomat-masc-primary)", "rgb": "rgb(240, 255, 245)" }, "font": "rgb(154, 52, 18)" }
    },
    "ENFJ": {
      "default": { "bg": { "var": "var(--color-teal-300)", "rgb": "rgb(137, 169, 161)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-diplomat-fem-primary)", "rgb": "rgb(187, 247, 208)" }, "font": "rgb(154, 52, 18)" },
      "male": { "bg": { "var": "var(--color-diplomat-masc-primary)", "rgb": "rgb(240, 255, 245)" }, "font": "rgb(154, 52, 18)" }
    },
    "ENFP": {
      "default": { "bg": { "var": "var(--color-yellow-200)", "rgb": "rgb(255, 255, 148)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-diplomat-fem-primary)", "rgb": "rgb(187, 247, 208)" }, "font": "rgb(154, 52, 18)" },
      "male": { "bg": { "var": "var(--color-diplomat-masc-primary)", "rgb": "rgb(240, 255, 245)" }, "font": "rgb(154, 52, 18)" }
    },
    "ISTJ": {
      "default": { "bg": { "var": "var(--color-blue-400)", "rgb": "rgb(88, 154, 240)" }, "font": "var(--color-cream)" },
      "female": { "bg": { "var": "var(--color-sentinel-fem-primary)", "rgb": "rgb(252, 248, 227)" }, "font": "rgb(101, 67, 33)" },
      "male": { "bg": { "var": "var(--color-sentinel-masc-primary)", "rgb": "rgb(245, 245, 220)" }, "font": "rgb(45, 69, 28)" }
    },
    "ISFJ": {
      "default": { "bg": { "var": "var(--color-pink-200)", "rgb": "rgb(252, 205, 220)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-sentinel-fem-primary)", "rgb": "rgb(252, 248, 227)" }, "font": "rgb(101, 67, 33)" },
      "male": { "bg": { "var": "var(--color-sentinel-masc-primary)", "rgb": "rgb(245, 245, 220)" }, "font": "rgb(45, 69, 28)" }
    },
    "ESTJ": {
      "default": { "bg": { "var": "var(--color-orange-500)", "rgb": "rgb(255, 145, 36)" }, "font": "var(--color-cream)" },
      "female": { "bg": { "var": "var(--color-sentinel-fem-primary)", "rgb": "rgb(252, 248, 227)" }, "font": "rgb(101, 67, 33)" },
      "male": { "bg": { "var": "var(--color-sentinel-masc-primary)", "rgb": "rgb(245, 245, 220)" }, "font": "rgb(45, 69, 28)" }
    },
    "ESFJ": {
      "default": { "bg": { "var": "var(--color-pink-500)", "rgb": "rgb(252, 86, 129)" }, "font": "var(--color-cream)" },
      "female": { "bg": { "var": "var(--color-sentinel-fem-primary)", "rgb": "rgb(252, 248, 227)" }, "font": "rgb(101, 67, 33)" },
      "male": { "bg": { "var": "var(--color-sentinel-masc-primary)", "rgb": "rgb(245, 245, 220)" }, "font": "rgb(45, 69, 28)" }
    },
    "ISTP": {
      "default": { "bg": { "var": "var(--color-teal-300)", "rgb": "rgb(137, 169, 161)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-explorer-fem-primary)", "rgb": "rgb(254, 240, 138)" }, "font": "rgb(161, 98, 7)" },
      "male": { "bg": { "var": "var(--color-explorer-masc-primary)", "rgb": "rgb(255, 248, 240)" }, "font": "rgb(153, 27, 27)" }
    },
    "ISFP": {
      "default": { "bg": { "var": "var(--color-lilac-300)", "rgb": "rgb(246, 187, 253)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-explorer-fem-primary)", "rgb": "rgb(254, 240, 138)" }, "font": "rgb(161, 98, 7)" },
      "male": { "bg": { "var": "var(--color-explorer-masc-primary)", "rgb": "rgb(255, 248, 240)" }, "font": "rgb(153, 27, 27)" }
    },
    "ESTP": {
      "default": { "bg": { "var": "var(--color-orange-500)", "rgb": "rgb(255, 145, 36)" }, "font": "var(--color-cream)" },
      "female": { "bg": { "var": "var(--color-explorer-fem-primary)", "rgb": "rgb(254, 240, 138)" }, "font": "rgb(161, 98, 7)" },
      "male": { "bg": { "var": "var(--color-explorer-masc-primary)", "rgb": "rgb(255, 248, 240)" }, "font": "rgb(153, 27, 27)" }
    },
    "ESFP": {
      "default": { "bg": { "var": "var(--color-yellow-200)", "rgb": "rgb(255, 255, 148)" }, "font": "var(--color-green-900)" },
      "female": { "bg": { "var": "var(--color-explorer-fem-primary)", "rgb": "rgb(254, 240, 138)" }, "font": "rgb(161, 98, 7)" },
      "male": { "bg": { "var": "var(--color-explorer-masc-primary)", "rgb": "rgb(255, 248, 240)" }, "font": "rgb(153, 27, 27)" }
    }
  }
}
```


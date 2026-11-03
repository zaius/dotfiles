# Git commits

- Match the existing `git log` style: one-line subject, sentence case, imperative,
  under ~60 chars, ending with a period. Never use `feat:` / `fix:` / `chore:` prefixes.
- Most commits should be the subject line and nothing else. Only add a body when the
  reason for the change isn't evident from the subject plus the diff.
- When a body is warranted, write bullet points, never prose paragraphs. One short
  bullet per discrete change.
- Don't restate the subject, don't add `Summary:` / `Changes made:` headings, and don't
  describe what the diff already shows. Bullets explain *why*, not *what*.

# Comments

- Use active voice, never passive.
- Explain what the code does, not the process we took to get there.

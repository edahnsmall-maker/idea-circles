# Keep the Dharma Alive: Idea Circles

Two small pages for Dharma Teacher Weekend 2026.

| Page | When | What it does |
| --- | --- | --- |
| `index.html` | All weekend | Two tabs. **Share an idea**: anyone shares an idea and says whether they'd lead, co-lead, be on a committee, or none. **See ideas**: everyone's ideas (without names), which people can like or join. |
| `join.html` | Sunday, after the closing circle | Shows the merged ideas. People pick lead, co-lead or join for each, and leave their name and email. |
| `sign.html` | Print before Saturday | Two letter-size signs with QR codes, one for each page. |

Answers are saved in Supabase. Visitors can **add** ideas, likes and joins, and can see idea text and counts. Nobody can see anyone's name or email through these pages.

## One-time setup

1. **Database.** In Supabase, open SQL Editor → New query, paste all of `schema.sql`, and click Run. Then do the same with `schema-2-ideas-tab.sql`. Together they add three tables (`ic_ideas`, `ic_signups`, `ic_reactions`) and one public list (`ic_ideas_public`), and touch nothing else.
   - To hide a spam or duplicate idea from the list: Table Editor → `ic_ideas` → tick `hidden` on that row.
2. **Keys.** In Supabase, Settings → API, copy the Project URL and the anon (or publishable) key into `config.js`. Never use the service_role key.
3. **Hosting.** In this repository on GitHub: Settings → Pages → Source: Deploy from a branch → `main`, folder `/ (root)`. The site appears at `https://edahnsmall-maker.github.io/idea-circles/` within a minute or two.
4. **Test.** Open the site on your phone, share a test idea, and check it appears in Supabase → Table Editor → `ic_ideas`. Delete the test row there.
5. **Print** `sign.html` (open it in a browser and print, letter size, background graphics on).

## Saturday night

1. In Supabase → Table Editor → `ic_ideas`, click Export → CSV.
2. Merge similar ideas into about 8–15, keeping track of who offered to lead.
3. Put the merged list in `ideas.json`, one entry per idea:

   ```json
   { "id": "sister-sanghas", "title": "Sister sanghas", "summary": "Pair small groups with a larger center for joint sits and teacher visits." }
   ```

   Keep each `id` short and never change it once people start signing up.
4. Commit `ideas.json`. The Sunday page shows the new list within a minute or two.

## After the weekend

Export `ic_reactions` (likes and joins) and `ic_signups` as CSV. Every idea with 3 or more people who joined gets its own email thread.

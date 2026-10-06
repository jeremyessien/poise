# poise

Motion for Flutter apps, built so your AI agent already knows it.

Every Flutter app I build ends up with me explaining the same things to my agent: put a spring on this press, add a light haptic there, bring the list in one item at a time, and keep it smooth on cheap phones. The agent gets close, but close in motion often looks like a bug, so I fix it by hand. Then the next project comes along and I explain it all over again.

poise is where those fixes live once and for all. It has motion tokens, components, and named motion recipes that I've watched run and tuned until they feel right. You copy them into your project and own the code, the same way shadcn/ui works on the web. It also ships with a skill your agent can read, so "use the settled reveal" means the same thing every time and you don't have to describe it from scratch.

Two ideas sit underneath all of it. Motion is part of a component, not decoration added afterwards: a button isn't done until its press feels right. And it has to hold up on the phones people actually own, not just on a simulator running on a MacBook.

It's early. I'm building it inside a real app, Jeats, and pulling pieces out as they prove themselves. Nothing here is ready to use yet.

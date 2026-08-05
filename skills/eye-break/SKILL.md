---
name: eye-break
description: Control the locally installed Now Look Far / EyeBreak macOS companion. Use when the user asks to inspect, pause, resume, start, stop, or change eye-protection reminders, work duration, idle detection, or says 护眼、休息眼睛、看看窗外、暂停提醒.
---

# Eye Break

Use the installed local CLI:

`~/Library/Application Support/NowLookFar/bin/now-look-far`

Never claim that EyeBreak records keys or screen content. It only checks elapsed
time since the last keyboard, mouse, or scroll activity.

## Commands

```bash
"$HOME/Library/Application Support/NowLookFar/bin/now-look-far" status
"$HOME/Library/Application Support/NowLookFar/bin/now-look-far" set-work 50
"$HOME/Library/Application Support/NowLookFar/bin/now-look-far" set-idle 5
"$HOME/Library/Application Support/NowLookFar/bin/now-look-far" pause 7200
"$HOME/Library/Application Support/NowLookFar/bin/now-look-far" resume
"$HOME/Library/Application Support/NowLookFar/bin/now-look-far" start
"$HOME/Library/Application Support/NowLookFar/bin/now-look-far" stop
```

Use seconds for `pause`. Accept work durations from 20–90 minutes and idle
durations from 1–15 minutes. Report resulting state after a change.

If the CLI is missing, do not invent an installation path. Direct the Agent to:

`https://github.com/stephninja028-creator/Now_look_far/blob/main/AGENT_INSTALL.md`

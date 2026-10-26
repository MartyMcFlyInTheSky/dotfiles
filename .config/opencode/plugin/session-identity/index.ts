import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "session-identity",
  setup(ctx) {
    if (ctx.options.enabled === false || ctx.options.prompt === false) return

    ctx.session.hook("context", (event) => {
      event.system.push({
        type: "text",
        text: `Session identity (opencode): your current sessionID is ${event.sessionID}.`,
      })
    })
  },
})

// THE PHANTOM: demo-lib-b is never declared in package.json.
// It arrives transitively via demo-lib-a — whether this line works
// depends entirely on your package manager's node_modules layout.
const b = require("demo-lib-b");
console.log("phantom import worked:", b.name, b.version);

function gsDashboards(positions, savePositionURL) {
  const grid = GridStack.init()

  grid.batchUpdate()
  GridStack.Utils.sort(positions).forEach(function (position) {
    const container = document.getElementById("query-" + position.id)
    if (!container) {
      return
    }
    const widget = grid.addWidget({x: position.x, y: position.y, w: position.w, h: position.h, id: position.id})
    widget.querySelector(".grid-stack-item-content").appendChild(container)
  })
  grid.commit()

  grid.on("change", function () {
    const positions = grid.engine.nodes.map(function (node) {
      return {id: node.id, x: node.x, y: node.y, w: node.w, h: node.h}
    })

    fetch(savePositionURL, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({dashboard: {positions: JSON.stringify(positions)}})
    })
  })
}

function gsDashboards(serializedData, savePositionURL) {
  var grid = GridStack.init();

  grid.on('added', function(e, items) {log('added', items)});
  grid.on('removed', function(e, items) {log('removed', items)});
  grid.on('change', function(e, items) {log('changed', items)});
  function log(type, items) {
    var str = '';
    items.forEach(function(item) { str += ' (id)=' + item.id + '(x,y)=' + item.x + ',' + item.y + '(w, h)=' + item.w + ',' + item.h; });
    console.log(type + ' ' + items.length + ' items.' + str );
    if (type === 'changed') saveGrid();
  }


  loadGrid = function() {
    grid.removeAll();
    var items = GridStack.Utils.sort(serializedData);
    grid.batchUpdate();
    items.forEach(function (node, idx) {
      grid.addWidget(`<div><div class="grid-stack-item-content" id="ga-${node.id}"></div></div>`, node);
    });
    grid.commit();
    $('.grid-stack-item-content').each(function(i,e) {
      const $e = $(e);
      $e.append($('#query-' + $e[0].id.split('-')[1]));
    });
  };

  saveGrid = function() {
    serializedData = [];
    grid.engine.nodes.forEach(function(node) {
      const id = node.el.children[0].children[0].id.split('-')[1];
      serializedData.push({
        id: id,
        x: node.x,
        y: node.y,
        w: node.w,
        h: node.h
      });
    });
    serializedDataFull = {
      'authenticity_token': document.querySelector('[name="csrf-token"]').content,
      dashboard: { 
        positions: JSON.stringify(serializedData)
      }
    };
    const j = JSON.stringify(serializedDataFull);
    fetch(savePositionURL, { method: 'PATCH', cache: 'no-cache', headers: { 'Content-Type': 'application/json' }, body: j}); 
    //document.querySelector('#saved-data').value = j; 
  };

  clearGrid = function() {
    grid.removeAll();
  }

  loadGrid();
}

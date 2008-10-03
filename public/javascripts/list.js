var ListBox = new Class({
  Extends:Box,
  
  initialize:function(el) {
    this.parent(el);
    this.refresh();
  },
  
  itemContainer:function() {
    return this.el.getElement('.items');
  },
  
  items:function() {
    return this.el.getElements('.item');
  },
  
  hat:function() {
    return this.el.getElement('h2')
  },
  
  actions:function() {
    return this.el.getElement('.actions');
  },
  
  options:function() {
    return this.el.getElement('.options');
  },
  
  checkBoxes:function() {
    return this.itemContainer.getElements('.check');
  },
  
  pages:function() {
    return this.el.getElements('.pagination a');
  },
  
  setCheckBoxes:function() {
    this.checkBoxes().each(function(checkbox){
      checkbox.addEvent('click', this.toggleCheckBox.bind(this,checkbox));
    });
  },
  
  toggleCheckBox:function(checkbox) {
    var call = new Request.HTML({
      'url':this.getCheckBoxUrl(checkbox)
    }, this).get();
  },
  
  getCheckBoxUrl:function(checkbox) {
    var item = checkbox.getParent('.item');
    return checkbox.getProperty('title');
  },
  
  setBehaviors:function() {
    this.parent();
    this.setOptionsBehaviors();
    this.makeListSortable();
  },
  
  setItemBehaviors:function() {
    this.items().each(function(item){
      item.addEvents({
        'mouseenter':this.focusItem.bind(this,item),
        'mouseleave':this.unfocusItem.bind(this,item)
      },this);
    },this);
  },
  
  setOptionsBehaviors:function() {
    var expand_options_bt = this.el.getElement('.expand_options');
    var collapse_options_bt = this.el.getElement('.collapse_options');
    if($defined(expand_options_bt)) {
      expand_options_bt.addEvent('click', this.expandOptions.bindWithEvent(this));
    }
    if($defined(collapse_options_bt)) {
      collapse_options_bt.addEvent('click', this.collapseOptions.bindWithEvent(this));
    }
  },
  
  setPagination:function() {
    this.pages().each(function(page) {
      page.addEvent('click',this.pageTo.bindWithEvent(this,page));
    },this);
  },
  
  pageTo:function(ev,page) {
      ev.preventDefault();
      this.showLoader();
      this.content().empty();
      
      var call = new Request.HTML({
        'url':page.getProperty('href'),
        'update':this.content(),
        'onSuccess':this.onPage.bind(this)
      }, this).get();
      return false;
  },
  
  onPage:function() {
    this.hideLoader();
    this.refresh();
  },
  
  refresh:function() {
    this.setPagination();
    this.setItemBehaviors();
  },
  
  hideLoader:function() {
    this.el.removeClass('loading');
  },
  
  showLoader:function() {
    this.el.addClass('loading');
  },
  
  unfocus:function() {
    this.parent();
    this.collapseOptions();
  },
  
  unfocusItem:function(item) {
    item.removeClass('hover');
    
  },
  
  focusItem:function(item) {
    item.addClass('hover');  
  },
  
  makeListSortable:function() {
   
    var sortable = new Sortables(this.content(), {
      constrain:true,
      clone:false,
      revert:true,
      onStart:function(item) {
        item.addClass('dragged');
      },
      onSort:function(item) { 
        // this.getElements('.item').each(function(item,i){
          // item.getElement('.rank').set('text', i+1);
        // });
      },
      onComplete:function(item) {
        item.removeClass('dragged');
      }
    });
  },
  
  expandOptions:function(ev) {
    ev.preventDefault();
    
    this.expand();
    this.options['scroll'].toElement(this.options());
   
  },
  
  collapseOptions:function() {
   
    if($defined(this.options['scroll'])) {
      this.options['scroll'].toTop()
    }
     
  }
});
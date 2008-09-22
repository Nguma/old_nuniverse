var ListBox = new Class({
  initialize:function(el) {
    this.el = el;
    this.refresh();
  },
  
  itemContainer:function() {
    return this.el.getElement('.items')
  },
  
  items:function() {
    return this.el.getElements('.item')
  },
  
  checkBoxes:function() {
    return this.itemContainer.getElements('.check') 
  },
  
  pages:function() {
    return this.el.getElements('.pagination a')
  },
  
  setCheckBoxes:function() {
    this.checkBoxes().each(function(checkbox){
      checkbox.addEvent('click', this.toggleCheckBox.bind(this,checkbox))
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
  
  setItemBehaviors:function() {
    items().each(function(item){
      item.addEvents({
        'mouseenter':function() {
           item.addClass('hover');
        },
        'mouseleave':function() {
          item.removeClass('hover');
        }
      });
    });
  },
  
  setPagination:function() {
    this.pages().each(function(page) {
      page.addEvent('click',this.pageTo.bindWithEvent(this,page));
    },this);
  },
  
  pageTo:function(ev,page) {
      ev.preventDefault();
      this.showLoader();
      this.itemContainer().empty();
      
      var call = new Request.HTML({
        'url':page.getProperty('href'),
        'update':this.itemContainer(),
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
  },
  
  hideLoader:function() {
    this.el.removeClass('loading');
  },
  
  showLoader:function() {
    this.el.addClass('loading');
  }
});
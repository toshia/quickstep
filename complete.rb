# -*- coding: utf-8 -*-

module Plugin::Quickstep
  class Complete < Gtk::TreeView

    def initialize(search_input)
      super(gen_store)
      append_column ::Gtk::TreeViewColumn.new("", ::Gtk::CellRendererPixbuf.new, pixbuf: Plugin::Quickstep::Store::COL_ICON)
      append_column ::Gtk::TreeViewColumn.new("", ::Gtk::CellRendererText.new, text: Plugin::Quickstep::Store::COL_TITLE)

      register_listeners(search_input)
    end

    private
    def register_listeners(search_input)
      search_input.ssc(:changed, &method(:input_change_event))
    end

    def input_change_event(widget)
      model = self.model = gen_store
      uri = Retriever::URI!(widget.text) if URI.regexp =~ widget.text
      model.add_model(uri) if uri
      false
    end

    def select_first_ifn(model, path, iter)
      Delayer.new do
        self.selection.select_path(path) unless self.selection.selected
      end
      false
    end

    def gen_store
      store = Store.new(GdkPixbuf::Pixbuf, String, Object)
      store.ssc(:row_inserted, &method(:select_first_ifn))
      store
    end
  end

  class Store < Gtk::ListStore
    COL_ICON  = 0
    COL_TITLE = 1
    COL_MODEL = 2

    def add_model(model)
      case model
      when Retriever::Model
        iter = append
        iter[COL_ICON] = nil # model.icon if model.respond_to?(icon)
        iter[COL_TITLE] = model.title
        iter[COL_MODEL] = model
      when Retriever::URI, URI::Generic, Addressable::URI, String
        iter = append
        iter[COL_ICON] = nil
        iter[COL_TITLE] = 'URLを開く: %{uri}' % {uri: model.to_s}
        iter[COL_MODEL] = model
      end
    end
  end
end

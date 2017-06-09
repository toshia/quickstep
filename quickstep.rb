# -*- coding: utf-8 -*-
require_relative 'complete'

Plugin.create(:quickstep) do
  command(:quickstep,
          name: 'Quick Step',
          condition: lambda{ |opt| true },
          visible: true,
          role: :window) do |opt|
    dialog = Gtk::Dialog.new
    dialog.window_position = Gtk::Window::POS_CENTER
    dialog.title = "Quick Step"
    dialog.add_button(Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT)
    register_listeners(dialog, put_widget(dialog.vbox))
    dialog.show_all
  end

  # URLっぽい文字列なら、それに対してintentを発行する候補を出す
  filter_quickstep_query do |query, yielder|
    if URI.regexp =~ query
      yielder << Retriever::URI!(query)
    end
    [query, yielder]
  end

  def put_widget(box)
    search = Gtk::Entry.new
    complete = Plugin::Quickstep::Complete.new(search)
    box.closeup(search).add(complete)
    complete
  end

  def register_listeners(dialog, treeview)
    dialog.ssc(:response) do |widget, response|
      case response
      when Gtk::Dialog::RESPONSE_ACCEPT
        selected = treeview.selection.selected
        p selected[Plugin::Quickstep::Store::COL_MODEL] if selected
        Plugin.call(:open, selected[Plugin::Quickstep::Store::COL_MODEL]) if selected
      end
      widget.destroy
      false
    end
  end
end

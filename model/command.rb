# -*- coding: utf-8 -*-

module Plugin::Quickstep
  class Command < Retriever::Model
    field.string :slug, required: true
    field.string :name, required: true
    field.string :role, required: true
    field.bool :visible

    register :quickstep_command, name: "mikutterコマンド(Quick Step)"

    def title
      name
    end
  end
end

module KindEditorWhiteList
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      ActionView::Base.send :include, WhiteListHelper
    end
  end
end

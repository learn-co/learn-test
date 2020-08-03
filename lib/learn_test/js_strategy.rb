# frozen_string_literal: true

module LearnTest
  module JsStrategy
    def js_package
      @js_package ||= File.exist?('package.json') ? Oj.load(File.read('package.json'), symbol_keys: true) : nil
    end

    def has_js_dependency?(dep)
      [:dependencies, :devDependencies].any? { |key| js_package[key] && js_package[key][dep] }
    end

    def modules_missing?(module_names)
      module_names.any? { |name| !File.exist?("node_modules/#{name}") }
    end

    def missing_dependencies?
      return true unless File.exist?('node_modules')
      [:dependencies, :devDependencies, :peerDependencies].any? do |dep_group|
        modules = js_package[dep_group] || {}
        modules_missing?(modules.keys)
      end
    end

    def npm_install
      run_install('npm install', npm_install: true) if missing_dependencies?
    end
  end
end

class Api::V1::BaseController < Api::BaseController
  before_action :set_language
  private

  def set_language
    language = params[:language].try(:downcase).try(:strip).try(:to_sym) ||
      :en
    I18n.locale = if [:en, :es, :fr].include?(language)
      language
    else
      I18n.default_locale
    end
  end

  def set_legislation_scope
    @legislation_scope = params[:scope].try(:downcase).try(:strip).try(:to_sym) ||
      :current
    unless [:all, :current, :historic].include?(@legislation_scope)
      @legislation_scope = :current
    end
  end
end

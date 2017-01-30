# encoding: utf-8

module Prodam::Idealize

class MensagensController < ApplicationController
  helpers IdeiasHelper, DateHelper

  before do
    @page = controllers[:mensagens]
  end

  get '/' do
    message.update level: :information, text: 'Em breve... aguarde.'
    redirect path_to :home
  end
end

end # module

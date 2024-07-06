# encoding: UTF-8
# frozen_string_literal: true


def mkdir(dossier)
  File.exist?(dossier) || `mkdir -p "#{dossier}"`
  dossier
end

class Hash

def to_sym
  h = {}  
  self.each do |k, v|
    h.merge!(k.to_sym => v, k.to_s => v)
  end
  return h
end

end

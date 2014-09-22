require 'openssl'
require 'digest/sha1'


# not working yet.
class Cipher
  attr_accessor :key , :iv , :cipher

  def initialize
    @key = Digest::SHA1.hexdigest("my-secret-password")
    @cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    @iv = @cipher.random_iv
  end
  def encrypt(message)
  
      @key = Digest::SHA1.hexdigest("my-secret-password")
      @iv = @cipher.random_iv
      @cipher.encrypt
      encrypted = @cipher.update(message)
      encrypted << @cipher.final
      return encrypted
  end

  def decrypt(encrypted)
      @cipher.decrypt
      @cipher.padding = 0
      decrypted = @cipher.update(encrypted)
      decrypted << @cipher.final
      return decrypted
  end
end
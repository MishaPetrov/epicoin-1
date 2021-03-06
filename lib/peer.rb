require 'openssl'
require 'base64'

class Peer < ActiveRecord::Base
  has_many :transfers
  before_create(:generate_keys)


  # encode message using senders private key
  def sign(plaintext, raw_private_key)
    private_key = OpenSSL::PKey::RSA.new(raw_private_key)
    @encoded_message = Base64.encode64(private_key.private_encrypt(plaintext))
  end

  #decode a message
  def plaintext(ciphertext, raw_public_key)
    public_key = OpenSSL::PKey::RSA.new(raw_public_key)
    begin
      public_key.public_decrypt(Base64.decode64(ciphertext))
    rescue
      ciphertext
    end
  end

  #sig is valid if decoding with public key matches original message
  def valid_signature?(message, ciphertext, public_key)
    message == plaintext(ciphertext, public_key)
  end

  private
  def generate_keys
    key_pair = OpenSSL::PKey::RSA.new(2048)
    self.private_key, self.public_key = key_pair.export, key_pair.public_key.export
  end
end
# public key, private key, balance
# have and belong to many transactions
# relates to blocks through transactionsn

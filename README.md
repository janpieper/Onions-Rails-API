Onions.io - Rails API/Website
================

This is the official repository of [Onions.io](https://www.onions.io), a secure cloud storage site for text snippets. Onions is perfect for passwords, personal information, or anything else that can be condensed down to characters. Onions is not secure file storage - with no plans to become that in the future (hosting costs, etc). This repository houses the Rails app used to power the API for client applications and the website.

*Onion* - An Onion is just a blob of text, that contains a title and info.

## Security Model ##

Security is absolutely the most important feature of Onions. It employs a few different implementations and philosophies to obfuscate your data in totality. To begin with, every connection made to the API and using the website is made over an **SSL** connection. You can verify this by checking out the address bar for the website.

**Accounts**

No emails or personal information is ever received when you create an account - just a username to identify it and a password. The downside of this is that your password can never be reset, or changed, or retrieved if you forget it. However, the upside of this model is that your account is practically anonymous assuming you don't choose a username that ties to you somehow (like firstnamelastname or your email). Beyond that, another security precaution is taken into account where your username is salted via a propietary salt that lives only on the server - something not in this repository. After salting, it is hashed using SHA-256, and then saved in the database. This will be regarded as HashedUser from here on out.

Your password is salted and hashed via the encryption library, [BCrypt](http://en.wikipedia.org/wiki/Bcrypt). The standard Ruby bcrypt library is employed in the app to handle this implementation.

A second salt is created using BCrypt for the next part of the app, encrypting/decrypting Onions. This leaves the Account object looking like this:

```ruby
// Account
+ HashedUser = SHA-256(username + SERVER_SALT)
+ HashedPass = BCrypt(password, 10 rounds)
+ Salt = BCrypt.Salt.new
```

**Onions**

No Onions are ever stored in plaintext on the server either. They are encrypted via [AES-256](http://en.wikipedia.org/wiki/Advanced_Encryption_Standard) encryption before ever being sent to the server to be saved in the database. Another modern cryptography implementation is employed to generate your private AES Key, [PBKDF2](http://en.wikipedia.org/wiki/PBKDF2). PBKDF2 is used with 20,000 rounds of key-stretching to generate your AES Key in both the client and website applications, and the specific algorithm is [HMAC-SHA1](http://en.wikipedia.org/wiki/Hash-based_message_authentication_code). Doing this makes it harder, or more time intensive, to brute-force your encryption key, and provides a level of security that meets contemporary standards.

An Onion has a title and info as its properties. The title is just an 80 character or less blurb about what is contained inside. The info is 800 characters or less and is the meat of what you are saving. Both of these fields are encrypted before being sent to the server - resulting in a data structure that looks like so:

```ruby
// AES Key
+ AES_Key = PBKDF2(HMAC_SHA1, (plaintext username + plaintext password), Account.Salt, 20000 iterations)

// Onion
+ HashedTitle = AES_Encrypt(title, AES_Key)
+ HashedInfo = AES_Encrypt(info, AES_Key)
+ HashedUser = Account.HashedUser
```

**Sessions**

The client applications are given Session objects after logging in, allowing them to retrieve, manipulate, create or delete Onions on the server. The Session object contains a Key, HashedUser and CreationDate properties used to guarantee authenticity and allowing the client to make changes. The Key property is a random GUID given at runtime that is matched to an Account that just logged in. The CreationDate is used to maintain an hour timeline on making changes to the server without having to log back in again.

The Session objects also roll after every action. Basically this means that on login you get a Session object - then after you create a new Onion, that Session object is deleted and a new one is given to the client. If you edit an Onion and save it, a new Session object is given to you. If you sit for an hour after logging in, and then try to manipulate the data, the client will log you out and return you to the login screen. The data model for this looks like so:

```ruby
// Session
+ Key = 32-bit GUID
+ HashedUser = Account.HashedUser
+ CreationDate = DateTime object
```
# API docs!
hey! i'm glad you're here. let's send some stuff to some people!!

**for the robots and their handlers:**

[append .md](/back_office/api-docs.md) to this URL or click this handy button to get an AI-slop friendly version of these docs.

the ones you're reading right now are for people to read with their eyes and understand with their brains.

%AI-COPY-BUTTON%

### authorization (the technical kind):

pretty easy. you'll need a Theseus back office API key - if you don't have one you can %API-KEY-BUTTON%

once you have it, just pass it in the `Authorization` header of your requests like so:

```
Authorization: Bearer th_apk_live_alskfjsdkfjksdjhf
```

### authorization (the other kind):
if you're planning on using the warehouse, talk to Zach/Nora first!

if you're sending letters, don't get us in trouble with the Postal Service.

if you're at all unsure whether your use case for the Theseus API is okay, please poke me!

it probably is, but continued access to this system is contingent on good behavior.

# Sending Mail
_(mail as in shipping vs. mailing, letters and flats and whatnot)_
## Two paths are before you.
**Instant Queues** and **Batch Queues**. both are powerful primitives for bringing the joy of mail into your program!

which one you'll use depends on what you're trying to do.

let's start with the popular one,
### Batch Queues:

Batch Queues are the simplest way to manage sending out large quantities of mail to Hack Clubbers.




~your pal, Nora
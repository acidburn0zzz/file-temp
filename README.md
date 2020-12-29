## Description
The file-temp library is an alternate way to handle tempfile generation.

## Requirements
* ffi 1.1.0 or later

## Installation
`gem install file-temp`

## Synopsis
```
require 'file/temp'

fh = File::Temp.new
fh.puts "hello"
fh.close # => Tempfile automatically deleted

fh = File::Temp.new(delete: false)
fh.puts "world"
fh.close # => Tempfile still on your filesystem
```

## Motivation
Unlike the tempfile library that ships with Ruby's standard library, this
library uses your system's native `tmpfile` or `mkstemp` functions.
   
This library is also more secure because it restricts file permission via
`umask` for files created with `mkstemp`.

Finally, this library subclasses the File class. This means you get almost
exactly the same interface as the File class. The only difference is the
constructor.

Note that my original motivation was a problem with race conditions in
the tempfile library, but that was a very long time ago, and my assumption
at this point is that it's no longer true. But, I still prefer this version
to the one in the Ruby standard library.

## JRuby
The implementation for JRuby uses the Java API, not the C API. The
temporary file name generated by Java is different than the C version,
since it uses a GUID instead of the 'XXXXXX' template, but the
interface is otherwise identical.

## MS Windows
You may need to use the mingw build in order to use this library.

Also, there was a bug with the `GetTempFileName` function on certain versions
of MS Windows that may cause a failure. However, if you'r patched up you
should not see it. 

## License
Apache-2.0

## Copyright
(C) 2007-2020 Daniel J. Berger
All Rights Reserved

## Warranty
This library is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author
Daniel J. Berger

## See also
tmpfile(), mkstemp(), tmpnam()

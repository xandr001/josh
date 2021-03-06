  $ export TESTTMP=${PWD}
  $ export PATH=${TESTDIR}/../../target/debug/:${PATH}

  $ cd ${TESTTMP}
  $ git init 1> /dev/null

  $ mkdir a
  $ echo contents1 > a/file1
  $ echo contents1 > a/file2
  $ git add a

  $ mkdir b
  $ echo contents1 > b/file1
  $ git add b

  $ mkdir -p c/d
  $ echo contents1 > c/d/file1
  $ git add c
  $ git commit -m "add files" 1> /dev/null

  $ git log --graph --pretty=%s
  * add files

  $ josh-filter master --update refs/josh/filtered :nosuch=filter

  $ git ls-tree --name-only -r refs/josh/filtered
  fatal: Not a valid object name refs/josh/filtered
  [128]

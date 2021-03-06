  $ . ${TESTDIR}/setup_test_env.sh
  $ cd ${TESTTMP}


  $ git clone -q http://localhost:8001/real_repo.git
  warning: You appear to have cloned an empty repository.

  $ curl -s http://localhost:8002/version
  Version: * (glob)

  $ cd real_repo

  $ git status
  On branch master
  
  No commits yet
  
  nothing to commit (create/copy files and use "git add" to track)

  $ git checkout -b master
  Switched to a new branch 'master'


  $ echo content1 > file1 1> /dev/null
  $ git add .
  $ git commit -m "initial" 1> /dev/null


  $ mkdir -p sub1/subsub1
  $ echo contents1 > sub1/subsub1/file1
  $ git add .
  $ git commit -m "add subsub1" 1> /dev/null

  $ mkdir -p sub1/subsub2
  $ echo contents1 > sub1/subsub2/file1
  $ git add .
  $ git commit -m "add subsub2" 1> /dev/null

  $ git push
  To http://localhost:8001/real_repo.git
   * [new branch]      master -> master

  $ cd ${TESTTMP}
  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git clone -q http://localhost:8002/real_repo.git:workspace=ws.git ws
  warning: You appear to have cloned an empty repository.
  $ cd ${TESTTMP}/ws
  $ cat > workspace.josh <<EOF
  > a/subsub1 = :/sub1/subsub1
  > a/subsub2 = :/sub1/subsub2
  > EOF

  $ git add .
  $ git commit -m "add workspace" 1> /dev/null
  $ git push origin HEAD:refs/heads/master%josh-merge
  remote: warning: ignoring broken ref refs/namespaces/* (glob)
  remote: josh-proxy        
  remote: response from upstream:        
  remote:  To http://localhost:8001/real_repo.git        
  remote:    *..* JOSH_PUSH -> master* (glob)
  remote: 
  remote: 
  To http://localhost:8002/real_repo.git:workspace=ws.git
   * [new branch]      HEAD -> master%josh-merge

  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git pull -q --rebase

  $ git log --graph --pretty=%s
  * Merge from :workspace=ws
  * add workspace

  $ cd ${TESTTMP}/real_repo
  $ git pull --rebase
  From http://localhost:8001/real_repo
     *..*  master     -> origin/master* (glob)
  Updating *..* (glob)
  Fast-forward
   ws/workspace.josh | 2 ++
   1 file changed, 2 insertions(+)
   create mode 100644 ws/workspace.josh

  $ git log --graph --pretty=%s
  *   Merge from :workspace=ws
  |\  
  | * add workspace
  * add subsub2
  * add subsub1
  * initial

  $ cd ${TESTTMP}/ws
  $ cat > workspace.josh <<EOF
  > a/ = :/sub1
  > EOF

  $ git add workspace.josh
  $ git commit -m "mod workspace" 1> /dev/null

  $ git log --graph --pretty=%s
  * mod workspace
  * Merge from :workspace=ws
  * add workspace


  $ git push
  remote: josh-proxy        
  remote: response from upstream:        
  remote:  converted Error { code: -1, klass: 14, message: "failed to insert entry: invalid name for a tree entry - a/" }        
  remote: 
  remote: 
  remote: error: hook declined to update refs/heads/master        
  To http://localhost:8002/real_repo.git:workspace=ws.git
   ! [remote rejected] master -> master (hook declined)
  error: failed to push some refs to 'http://localhost:8002/real_repo.git:workspace=ws.git'
  [1]

  $ cd ${TESTTMP}/ws
  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git pull --rebase
  Current branch master is up to date.

  $ tree
  .
  |-- a
  |   |-- subsub1
  |   |   `-- file1
  |   `-- subsub2
  |       `-- file1
  `-- workspace.josh
  
  3 directories, 3 files

  $ git log --graph --pretty=%s
  * mod workspace
  * Merge from :workspace=ws
  * add workspace

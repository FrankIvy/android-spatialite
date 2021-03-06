# VC++ 6.0 Makefile for SQLite 3.5.4

#### The toplevel directory of the source tree.  This is the directory
#    that contains this "Makefile.in" and the "configure.in" script.

TOP = ..\sqlite-3.5.4

#### C Compiler and options for use in building executables that
#    will run on the platform that is doing the build.

BCC = cl -Gs -GX -D_WIN32 -nologo -Zi

#### Leave MEMORY_DEBUG undefined for maximum speed.  Use MEMORY_DEBUG=1
#    to check for memory leaks.  Use MEMORY_DEBUG=2 to print a log of all
#    malloc()s and free()s in order to track down memory leaks.
#    
#    SQLite uses some expensive assert() statements in the inner loop.
#    You can make the library go almost twice as fast if you compile
#    with -DNDEBUG=1

#OPTS = -DMEMORY_DEBUG=2
#OPTS = -DMEMORY_DEBUG=1
#OPTS = 
OPTS = -DNDEBUG=1

#### The suffix to add to executable files.  ".exe" for windows.
#    Nothing for unix.

EXE = .exe

#### C Compile and options for use in building executables that 
#    will run on the target platform.  This is usually the same
#    as BCC, unless you are cross-compiling.

TCC = cl -Gs -GX -D_WIN32 -nologo -Zi -DOS_WIN=1

# You should not have to change anything below this line
###############################################################################

# This is how we compile

TCCX = $(TCC) $(OPTS) -DWIN32=1 -DTHREADSAFE=1 -DOS_WIN=1 \
	-DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_SOUNDEX=1 \
	-DSQLITE_OMIT_LOAD_EXTENSION=1 -I. -I$(TOP)/src

TCCXD = $(TCCX) -D_DLL

# Object files for the SQLite library.

LIBOBJ = alter.obj analyze.obj attach.obj auth.obj btmutex.obj btree.obj \
	 build.obj callback.obj complete.obj \
	 date.obj delete.obj expr.obj func.obj hash.obj insert.obj \
	 journal.obj loadext.obj main.obj malloc.obj mem1.obj mem2.obj \
	 mem3.obj mem4.obj mutex.obj mutex_w32.obj opcodes.obj os.obj \
	 os_win.obj \
	 pager.obj parse.obj pragma.obj prepare.obj printf.obj random.obj \
	 select.obj table.obj tokenize.obj trigger.obj update.obj \
	 util.obj vacuum.obj vdbe.obj vdbeapi.obj vdbeaux.obj vdbeblob.obj \
	 vdbefifo.obj vdbemem.obj \
	 where.obj utf.obj legacy.obj vtab.obj

# All of the source code files.

SRC = \
  $(TOP)/src/alter.c \
  $(TOP)/src/analyze.c \
  $(TOP)/src/attach.c \
  $(TOP)/src/auth.c \
  $(TOP)/src/btmutex.c \
  $(TOP)/src/btree.c \
  $(TOP)/src/btree.h \
  $(TOP)/src/btreeInt.h \
  $(TOP)/src/build.c \
  $(TOP)/src/callback.c \
  $(TOP)/src/complete.c \
  $(TOP)/src/date.c \
  $(TOP)/src/delete.c \
  $(TOP)/src/expr.c \
  $(TOP)/src/func.c \
  $(TOP)/src/hash.c \
  $(TOP)/src/hash.h \
  $(TOP)/src/insert.c \
  $(TOP)/src/journal.c \
  $(TOP)/src/legacy.c \
  $(TOP)/src/loadext.c \
  $(TOP)/src/main.c \
  $(TOP)/src/malloc.c \
  $(TOP)/src/mem1.c \
  $(TOP)/src/mem2.c \
  $(TOP)/src/mem3.c \
  $(TOP)/src/mem4.c \
  $(TOP)/src/mutex.c \
  $(TOP)/src/mutex.h \
  $(TOP)/src/mutex_w32.c \
  $(TOP)/src/os.c \
  $(TOP)/src/os.h \
  $(TOP)/src/os_win.c \
  $(TOP)/src/pager.c \
  $(TOP)/src/pager.h \
  $(TOP)/src/parse.y \
  $(TOP)/src/pragma.c \
  $(TOP)/src/prepare.c \
  $(TOP)/src/printf.c \
  $(TOP)/src/random.c \
  $(TOP)/src/select.c \
  $(TOP)/src/shell.c \
  $(TOP)/src/sqlite.h.in \
  $(TOP)/src/sqlite3ext.h \
  $(TOP)/src/sqliteInt.h \
  $(TOP)/src/sqliteLimit.h \
  $(TOP)/src/table.c \
  $(TOP)/src/tokenize.c \
  $(TOP)/src/trigger.c \
  $(TOP)/src/utf.c \
  $(TOP)/src/update.c \
  $(TOP)/src/util.c \
  $(TOP)/src/vacuum.c \
  $(TOP)/src/vdbe.c \
  $(TOP)/src/vdbe.h \
  $(TOP)/src/vdbeapi.c \
  $(TOP)/src/vdbeaux.c \
  $(TOP)/src/vdbeblob.c \
  $(TOP)/src/vdbefifo.c \
  $(TOP)/src/vdbemem.c \
  $(TOP)/src/vdbeInt.h \
  $(TOP)/src/vtab.c \
  $(TOP)/src/where.c

# Header files used by all library source files.

HDR = \
   sqlite3.h  \
   $(TOP)/src/btree.h \
   $(TOP)/src/btreeInt.h \
   $(TOP)/src/hash.h \
   $(TOP)/src/sqliteLimit.h \
   opcodes.h \
   $(TOP)/src/os.h \
   $(TOP)/src/os_common.h \
   $(TOP)/src/sqlite3ext.h  \
   $(TOP)/src/sqliteInt.h  \
   $(TOP)/src/vdbe.h  \
   parse.h

# Header files used by the VDBE submodule

VDBEHDR = \
   $(HDR) \
   $(TOP)/src/vdbeInt.h

# This is the default Makefile target.  The objects listed here
# are what get build when you type just "make" with no arguments.

all:	sqlite3.h sqlite3.dll libsqlite3.lib sqlite3.exe

sqlite3.dll:	$(LIBOBJ) sqlite3.def
	echo #include "sqlite3.h" > version.c
	echo const char sqlite3_version[] = SQLITE_VERSION; >> version.c
	$(TCCX) -c version.c
	link -release -nodefaultlib -dll msvcrt.lib kernel32.lib \
	    -def:$(TOP)\sqlite3.def -out:$@ $(LIBOBJ)
	lib sqlite3.lib version.obj

libsqlite3.lib:	$(LIBOBJ)
	lib -out:$@ $(LIBOBJ)

sqlite3.exe:	sqlite3.dll
	$(TCCX) -o $@ $(TOP)/src/shell.c sqlite3.lib

# Rules to build the LEMON compiler generator

lemon:	$(TOP)/tool/lemon.c $(TOP)/tool/lempar.c
	$(BCC) -o lemon $(TOP)/tool/lemon.c
	copy $(TOP)\tool\lempar.c .

keywordhash.h:	$(TOP)/tool/mkkeywordhash.c
	$(BCC) -o mkkwhash $(OPTS) $(TOP)/tool/mkkeywordhash.c
	.\mkkwhash > keywordhash.h

alter.obj:	$(TOP)/src/alter.c $(HDR)
	$(TCCXD) -c $(TOP)/src/alter.c

analyze.obj:	$(TOP)/src/analyze.c $(HDR)
	$(TCCXD) -c $(TOP)/src/analyze.c

attach.obj:	$(TOP)/src/attach.c $(HDR)
	$(TCCXD) -c $(TOP)/src/attach.c

auth.obj:	$(TOP)/src/auth.c $(HDR)
	$(TCCXD) -c $(TOP)/src/auth.c

btmutex.obj:	$(TOP)/src/btmutex.c $(HDR)
	$(TCCXD) -c $(TOP)/src/btmutex.c

btree.obj:	$(TOP)/src/btree.c $(HDR) $(TOP)/src/pager.h
	$(TCCXD) -c $(TOP)/src/btree.c

build.obj:	$(TOP)/src/build.c $(HDR)
	$(TCCXD) -c $(TOP)/src/build.c

callback.obj:	$(TOP)/src/callback.c $(HDR)
	$(TCCXD) -c $(TOP)/src/callback.c

complete.obj:	$(TOP)/src/complete.c $(HDR)
	$(TCCXD) -c $(TOP)/src/complete.c

date.obj:	$(TOP)/src/date.c $(HDR)
	$(TCCXD) -c $(TOP)/src/date.c

delete.obj:	$(TOP)/src/delete.c $(HDR)
	$(TCCXD) -c $(TOP)/src/delete.c

expr.obj:	$(TOP)/src/expr.c $(HDR)
	$(TCCXD) -c $(TOP)/src/expr.c

func.obj:	$(TOP)/src/func.c $(HDR)
	$(TCCXD) -c $(TOP)/src/func.c

hash.obj:	$(TOP)/src/hash.c $(HDR)
	$(TCCXD) -c $(TOP)/src/hash.c

insert.obj:	$(TOP)/src/insert.c $(HDR)
	$(TCCXD) -c $(TOP)/src/insert.c

journal.obj:	$(TOP)/src/journal.c $(HDR)
	$(TCCXD) -c $(TOP)/src/journal.c

legacy.obj:	$(TOP)/src/legacy.c $(HDR)
	$(TCCXD) -c $(TOP)/src/legacy.c

loadext.obj:	$(TOP)/src/loadext.c $(HDR)
	$(TCCXD) -c $(TOP)/src/loadext.c

main.obj:	$(TOP)/src/main.c $(HDR)
	$(TCCXD) -c $(TOP)/src/main.c

mem1.obj:	$(TOP)/src/mem1.c $(HDR)
	$(TCCXD) -c $(TOP)/src/mem1.c

mem2.obj:	$(TOP)/src/mem2.c $(HDR)
	$(TCCXD) -c $(TOP)/src/mem2.c

mem3.obj:	$(TOP)/src/mem3.c $(HDR)
	$(TCCXD) -c $(TOP)/src/mem3.c

mem4.obj:	$(TOP)/src/mem4.c $(HDR)
	$(TCCXD) -c $(TOP)/src/mem4.c

malloc.obj:	$(TOP)/src/malloc.c $(HDR)
	$(TCCXD) -c $(TOP)/src/malloc.c

mutex.obj:	$(TOP)/src/mutex.c $(HDR)
	$(TCCXD) -c $(TOP)/src/mutex.c

mutex_w32.obj:	$(TOP)/src/mutex_w32.c $(HDR)
	$(TCCXD) -c $(TOP)/src/mutex_w32.c

pager.obj:	$(TOP)/src/pager.c $(HDR) $(TOP)/src/pager.h
	$(TCCXD) -c $(TOP)/src/pager.c

opcodes.obj:	opcodes.c $(HDR)
	$(TCCXD) -c opcodes.c

os.obj:	$(TOP)/src/os.c $(HDR)
	$(TCCXD) -c $(TOP)/src/os.c

os_win.obj:	$(TOP)/src/os_win.c $(HDR)
	$(TCCXD) -c $(TOP)/src/os_win.c

parse.h:	parse.c

parse.obj:	parse.c $(HDR)
	$(TCCXD) -c parse.c

parse.c:	$(TOP)/src/parse.y lemon
	copy $(TOP)\src\parse.y .
	.\lemon parse.y

pragma.obj:	$(TOP)/src/pragma.c $(HDR)
	$(TCCXD) -c $(TOP)/src/pragma.c

prepare.obj:	$(TOP)/src/prepare.c $(HDR)
	$(TCCXD) -c $(TOP)/src/prepare.c

printf.obj:	$(TOP)/src/printf.c $(HDR)
	$(TCCXD) -c $(TOP)/src/printf.c

random.obj:	$(TOP)/src/random.c $(HDR)
	$(TCCXD) -c $(TOP)/src/random.c

select.obj:	$(TOP)/src/select.c $(HDR)
	$(TCCXD) -c $(TOP)/src/select.c

table.obj:	$(TOP)/src/table.c $(HDR)
	$(TCCXD) -c $(TOP)/src/table.c

tokenize.obj:	$(TOP)/src/tokenize.c keywordhash.h $(HDR)
	$(TCCXD) -c $(TOP)/src/tokenize.c

trigger.obj:	$(TOP)/src/trigger.c $(HDR)
	$(TCCXD) -c $(TOP)/src/trigger.c

update.obj:	$(TOP)/src/update.c $(HDR)
	$(TCCXD) -c $(TOP)/src/update.c

utf.obj:	$(TOP)/src/utf.c $(HDR)
	$(TCCXD) -c $(TOP)/src/utf.c

util.obj:	$(TOP)/src/util.c $(HDR)
	$(TCCXD) -c $(TOP)/src/util.c

vacuum.obj:	$(TOP)/src/vacuum.c $(HDR)
	$(TCCXD) -c $(TOP)/src/vacuum.c

vdbe.obj:	$(TOP)/src/vdbe.c $(VDBEHDR)
	$(TCCXD) -c $(TOP)/src/vdbe.c

vdbeapi.obj:	$(TOP)/src/vdbeapi.c $(VDBEHDR)
	$(TCCXD) -c $(TOP)/src/vdbeapi.c

vdbeaux.obj:	$(TOP)/src/vdbeaux.c $(VDBEHDR)
	$(TCCXD) -c $(TOP)/src/vdbeaux.c

vdbeblob.obj:	$(TOP)/src/vdbeblob.c $(VDBEHDR)
	$(TCCXD) -c $(TOP)/src/vdbeblob.c

vdbefifo.obj:	$(TOP)/src/vdbefifo.c $(VDBEHDR)
	$(TCCXD) -c $(TOP)/src/vdbefifo.c

vdbemem.obj:	$(TOP)/src/vdbemem.c $(VDBEHDR)
	$(TCCXD) -c $(TOP)/src/vdbemem.c

vtab.obj:	$(TOP)/src/vtab.c $(HDR)
	$(TCCXD) -c $(TOP)/src/vtab.c

where.obj:	$(TOP)/src/where.c $(HDR)
	$(TCCXD) -c $(TOP)/src/where.c

sqlite3.h:	$(TOP)/src/sqlite.h.in
	..\fixup < $(TOP)\src\sqlite.h.in > sqlite3.h \
	    --VERS-- @$(TOP)\VERSION \
	    --VERSION-NUMBER-- @@$(TOP)\VERSION

opcodes.h:	$(TOP)/src/vdbe.c parse.h
	..\mkopc3 <$(TOP)/src/vdbe.c parse.h
	..\fixup < opcodes.c > opcodes.new \
	    sqliteOpcodeNames sqlite3OpcodeNames
	del opcodes.c
	ren opcodes.new opcodes.c

sqlite3.def:	sqlite3.h
	echo LIBRARY SQLITE3 > sqlite3.def
	echo DESCRIPTION 'SQLite3 Library' >> sqlite3.def
	echo EXPORTS >> sqlite3.def
	echo sqlite3_aggregate_context >> sqlite3.def
	echo sqlite3_aggregate_count >> sqlite3.def
	echo sqlite3_bind_blob >> sqlite3.def
	echo sqlite3_bind_double >> sqlite3.def
	echo sqlite3_bind_int >> sqlite3.def
	echo sqlite3_bind_int64 >> sqlite3.def
	echo sqlite3_bind_null >> sqlite3.def
	echo sqlite3_bind_parameter_count >> sqlite3.def
	echo sqlite3_bind_parameter_index >> sqlite3.def
	echo sqlite3_bind_parameter_name >> sqlite3.def
	echo sqlite3_bind_text >> sqlite3.def
	echo sqlite3_bind_text16 >> sqlite3.def
	echo sqlite3_bind_value >> sqlite3.def
	echo sqlite3_bind_zeroblob >> sqlite3.def
	echo sqlite3_busy_handler >> sqlite3.def
	echo sqlite3_busy_timeout >> sqlite3.def
	echo sqlite3_changes >> sqlite3.def
	echo sqlite3_clear_bindings >> sqlite3.def
	echo sqlite3_close >> sqlite3.def
	echo sqlite3_collation_needed >> sqlite3.def
	echo sqlite3_collation_needed16 >> sqlite3.def
	echo sqlite3_column_blob >> sqlite3.def
	echo sqlite3_column_bytes >> sqlite3.def
	echo sqlite3_column_bytes16 >> sqlite3.def
	echo sqlite3_column_count >> sqlite3.def
	echo sqlite3_column_database_name >> sqlite3.def
	echo sqlite3_column_database_name16 >> sqlite3.def
	echo sqlite3_column_decltype >> sqlite3.def
	echo sqlite3_column_decltype16 >> sqlite3.def
	echo sqlite3_column_double >> sqlite3.def
	echo sqlite3_column_int >> sqlite3.def
	echo sqlite3_column_int64 >> sqlite3.def
	echo sqlite3_column_name >> sqlite3.def
	echo sqlite3_column_name16 >> sqlite3.def
	echo sqlite3_column_origin_name >> sqlite3.def
	echo sqlite3_column_origin_name16 >> sqlite3.def
	echo sqlite3_column_table_name >> sqlite3.def
	echo sqlite3_column_table_name16 >> sqlite3.def
	echo sqlite3_column_text >> sqlite3.def
	echo sqlite3_column_text16 >> sqlite3.def
	echo sqlite3_column_type >> sqlite3.def
	echo sqlite3_column_value >> sqlite3.def
	echo sqlite3_commit_hook >> sqlite3.def
	echo sqlite3_complete >> sqlite3.def
	echo sqlite3_complete16 >> sqlite3.def
	echo sqlite3_create_collation >> sqlite3.def
	echo sqlite3_create_collation16 >> sqlite3.def
	echo sqlite3_create_collation_v2 >> sqlite3.def
	echo sqlite3_create_function >> sqlite3.def
	echo sqlite3_create_function16 >> sqlite3.def
	echo sqlite3_create_module >> sqlite3.def
	echo sqlite3_data_count >> sqlite3.def
	echo sqlite3_db_handle >> sqlite3.def
	echo sqlite3_declare_vtab >> sqlite3.def
	echo sqlite3_enable_shared_cache >> sqlite3.def
	echo sqlite3_errcode >> sqlite3.def
	echo sqlite3_errmsg >> sqlite3.def
	echo sqlite3_errmsg16 >> sqlite3.def
	echo sqlite3_exec >> sqlite3.def
	echo sqlite3_expired >> sqlite3.def
	echo sqlite3_extended_result_codes >> sqlite3.def
	echo sqlite3_finalize >> sqlite3.def
	echo sqlite3_free >> sqlite3.def
	echo sqlite3_free_table >> sqlite3.def
	echo sqlite3_get_autocommit >> sqlite3.def
	echo sqlite3_get_auxdata >> sqlite3.def
	echo sqlite3_get_table >> sqlite3.def
	echo sqlite3_global_recover >> sqlite3.def
	echo sqlite3_interrupt >> sqlite3.def
	echo sqlite3_io_trace >> sqlite3.def
	echo sqlite3_last_insert_rowid >> sqlite3.def
	echo sqlite3_libversion >> sqlite3.def
	echo sqlite3_libversion_number >> sqlite3.def
	echo sqlite3_malloc >> sqlite3.def
	echo sqlite3_mprintf >> sqlite3.def
	echo sqlite3_open >> sqlite3.def
	echo sqlite3_open16 >> sqlite3.def
	echo sqlite3_overload_function >> sqlite3.def
	echo sqlite3_prepare >> sqlite3.def
	echo sqlite3_prepare16 >> sqlite3.def
	echo sqlite3_prepare16_v2 >> sqlite3.def
	echo sqlite3_prepare_v2 >> sqlite3.def
	echo sqlite3_profile >> sqlite3.def
	echo sqlite3_progress_handler >> sqlite3.def
	echo sqlite3_realloc >> sqlite3.def
	echo sqlite3_reset >> sqlite3.def
	echo sqlite3_result_blob >> sqlite3.def
	echo sqlite3_result_double >> sqlite3.def
	echo sqlite3_result_error >> sqlite3.def
	echo sqlite3_result_error16 >> sqlite3.def
	echo sqlite3_result_error_toobig >> sqlite3.def
	echo sqlite3_result_int >> sqlite3.def
	echo sqlite3_result_int64 >> sqlite3.def
	echo sqlite3_result_null >> sqlite3.def
	echo sqlite3_result_text >> sqlite3.def
	echo sqlite3_result_text16 >> sqlite3.def
	echo sqlite3_result_text16be >> sqlite3.def
	echo sqlite3_result_text16le >> sqlite3.def
	echo sqlite3_result_value >> sqlite3.def
	echo sqlite3_result_zeroblob >> sqlite3.def
	echo sqlite3_rollback_hook >> sqlite3.def
	echo sqlite3_set_authorizer >> sqlite3.def
	echo sqlite3_set_auxdata >> sqlite3.def
	echo sqlite3_sleep >> sqlite3.def
	echo sqlite3_snprintf >> sqlite3.def
	echo sqlite3_step >> sqlite3.def
	echo sqlite3_table_column_metadata >> sqlite3.def
	echo sqlite3_temp_directory >> sqlite3.def
	echo sqlite3_thread_cleanup >> sqlite3.def
	echo sqlite3_total_changes >> sqlite3.def
	echo sqlite3_trace >> sqlite3.def
	echo sqlite3_transfer_bindings >> sqlite3.def
	echo sqlite3_update_hook >> sqlite3.def
	echo sqlite3_user_data >> sqlite3.def
	echo sqlite3_value_blob >> sqlite3.def
	echo sqlite3_value_bytes >> sqlite3.def
	echo sqlite3_value_bytes16 >> sqlite3.def
	echo sqlite3_value_double >> sqlite3.def
	echo sqlite3_value_int >> sqlite3.def
	echo sqlite3_value_int64 >> sqlite3.def
	echo sqlite3_value_numeric_type >> sqlite3.def
	echo sqlite3_value_text >> sqlite3.def
	echo sqlite3_value_text16 >> sqlite3.def
	echo sqlite3_value_text16be >> sqlite3.def
	echo sqlite3_value_text16le >> sqlite3.def
	echo sqlite3_value_type >> sqlite3.def
	echo sqlite3_version >> sqlite3.def
	echo sqlite3_vmprintf >> sqlite3.def
	echo sqlite3_vfs_find >> sqlite3.def
	echo sqlite3_vfs_register >> sqlite3.def
	echo sqlite3_vfs_unregister >> sqlite3.def

clean:
	del *.obj
	del *.pdb
	del *.dll
	del *.lib
	del *.exe
	del sqlite3.h
	del keywordhash.h
	del opcodes.h
	del opcodes.c
	del parse.h
	del parse.c

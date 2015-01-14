# modified BSD license
# Copyright (c) 2014, Gergely Mincsovics
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the author nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'time'
require 'pathname'

module Configuration

	Input=['FOLDER3MERGE_SKIPLISTFILE',
	'FOLDER3MERGE_OTHER', 'FOLDER3MERGE_BASE', 'FOLDER3MERGE_YOURS']
	Input.each {|i| raise 'Missing input environment variable: '+i if ENV[i].nil? }

	SKIPLISTFILE = ENV['FOLDER3MERGE_SKIPLISTFILE']
	OTHER_FOLDER = ENV['FOLDER3MERGE_OTHER']
	BASE_FOLDER  = ENV['FOLDER3MERGE_BASE']
	YOURS_FOLDER = ENV['FOLDER3MERGE_YOURS']
	OUTPUT_FOLDER= ENV['FOLDER3MERGE_OUTPUT'].nil? ? 'OUTPUT' : ENV['FOLDER3MERGE_OUTPUT']
	OUTPUTFILE   = ENV['FOLDER3MERGE_OUTPUTFILE'].nil? ? OUTPUT_FOLDER + 'folder3merge_start_merge.bat' : ENV['FOLDER3MERGE_OUTPUTFILE']
	MERGETOOL    = ENV['FOLDER3MERGE_MERGETOOL'].nil? ? 'MERGETOOL' : ENV['FOLDER3MERGE_MERGETOOL']

	EXCLUDE_REGEXP = Regexp.new("\.svn")

	NEWFOLDER='mkdir OUTFOLDER'
	USEOTHER='xcopy OTHER OUTFOLDER //d'
	USEYOURS='xcopy YOURS OUTFOLDER //d'
	REMOVEBASE='echo "skipping BASE (base) because it was removed in other"'
	REMOVEYOURS='echo "skipping YOURS (yours) because it was removed in other"'
	DOMERGE='IF NOT EXIST OUTPUT ( echo "" > OUTPUT && MERGETOOL BASE OTHER YOURS OUTPUT )'
	DOMERGENOBASE='echo "" > OUTPUT && MERGETOOL OTHER OTHER YOURS OUTPUT'

	MERGE3RESULT= { ['oby','oby'] => USEOTHER,
					['oby','ob']  => DOMERGE,
					['oby','by']  => USEOTHER,
					['oby','oy']  => USEOTHER,
					['oby','']    => DOMERGE,
					['ob','ob']   => USEOTHER,
					['ob','']     => USEOTHER,
					['by','by']   => REMOVEYOURS,
					['by','']     => REMOVEYOURS,
					['oy','oy']   => USEOTHER,
					['oy','']     => DOMERGENOBASE,
					['o','']      => USEOTHER,
					['b','']      => REMOVEBASE,
					['y','']      => USEYOURS }
end

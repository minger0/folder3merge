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

require 'ftools'
require 'fileutils'
require 'time'

load('Configuration.rb')
p 'SKIPLISTFILE = ' + Configuration::SKIPLISTFILE
p 'OTHER_FOLDER = ' + Configuration::OTHER_FOLDER
p 'BASE_FOLDER  = ' + Configuration::BASE_FOLDER
p 'YOURS_FOLDER = ' + Configuration::YOURS_FOLDER
p 'OUTPUTFILE   = ' + Configuration::OUTPUTFILE

p 'Reading the skip list'
skiplist=[]
if File.file?(Configuration::SKIPLISTFILE)
    skiplistfile = File.new(Configuration::SKIPLISTFILE, "r")
    begin
        while (record = skiplistfile.readline)
            skiplist.push(record.chomp.split[0]) # use just the first column
        end
    rescue EOFError
        skiplistfile.close
    end
end

Dir.pwd

p 'Building up the existhash'
existhash={}
folders={ 'o' => Configuration::OTHER_FOLDER, 
          'b' => Configuration::BASE_FOLDER,
          'y' => Configuration::YOURS_FOLDER }
folders.each do |role,folder|
    Dir.glob( File.join(folder, '**', '*'), File::FNM_DOTMATCH ) do |filename|
        next if !File.file?(filename)
        next if !Configuration::EXCLUDE_REGEXP.match(filename).nil?
        relpathfilename=Pathname(filename).relative_path_from(Pathname(folder)).to_s
        next if skiplist.include?(relpathfilename)
        existhash[relpathfilename]='' if existhash[relpathfilename].nil?
        existhash[relpathfilename]+=role
    end
end

p 'Writing out the merge results'
outfile = File.new(Configuration::OUTPUTFILE, 'w')
prevfolder='.'
existhash.each do |relpathfilename,existroles|
    equal=''
    f={ 'o' => '', 'b' => '', 'y' => '' }
    existroles.each_char do |role|
        f[role] = Pathname.new(File.join(folders[role],relpathfilename)).realpath.to_s
    end
    existroles.split("").each_with_index do |role1,idx1|
        existroles.split("").each_with_index do |role2,idx2|
            next if idx1>=idx2
            next if equal.size == folders.size
            if File.size(f[role1]) == File.size(f[role2])
                if FileUtils.cmp(f[role1], f[role2])
                    equal+=role1 if !equal.include?(role1)
                    equal+=role2 if !equal.include?(role2)
                end
            end
        end
    end
    
    currentfolder = Pathname.new(relpathfilename).dirname.to_s
    outputfilename= Configuration::OUTPUT_FOLDER+relpathfilename
    outputfolder  = Configuration::OUTPUT_FOLDER+currentfolder
    outfile.write(Configuration::NEWFOLDER.gsub('OUTFOLDER',outputfolder).gsub('/','\\')+"\n") if prevfolder!=currentfolder
    prevfolder = currentfolder
    
    mergeresult = Configuration::MERGE3RESULT[[existroles,equal]]
    p existroles+',' +equal+' => '+mergeresult
    mres=mergeresult.gsub('OTHER',f['o']).gsub('BASE',f['b']).gsub('YOURS',f['y']).gsub('OUTPUT',outputfilename).gsub('OUTFOLDER',outputfolder).gsub('MERGETOOL',Configuration::MERGETOOL).gsub('/','\\').gsub('\\\\','/')
    outfile.write(mres+"\n")
    $stdout.write(mres+"\n")
end
outfile.close()

$stdout.flush

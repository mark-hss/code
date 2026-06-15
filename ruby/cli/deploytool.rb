#!/usr/bin/env ruby
#Tool to deploy and backup
##copies src to dst and also makes a backup
#update the DEFAULTS.
require 'optparse'
require 'find'
require 'fileutils'

DEFAULTS = {
  src_dir: File.expand_path('./test'),
  dst_dir: File.expand_path('./prod'),
  backup_dir: File.expand_path('./backup')
}.freeze

options = {
  src_dir: DEFAULTS[:src_dir],
  dst_dir: DEFAULTS[:dst_dir],
  backup_dir: DEFAULTS[:backup_dir],
  file_type: DEFAULTS[:file_type],
  dry_run: false,
  verbose: false,
  prune: false,
  force: false
}

OptionParser.new do |op|
  op.banner = "Usage: proeval [options]"
  op.on('-s DIR', '--src DIR', 'Path to production directory') { |v| options[:src_dir] = File.expand_path(v) }
  op.on('-d DIR', '--dst DIR', 'Path to test directory') { |v| options[:dst_dir] = File.expand_path(v) }
  op.on('--backup DIR', 'Path to backup directory') { |v| options[:backup_dir] = File.expand_path(v) }
  op.on('--dry-run', 'Print actions but nothing will be changed') { options[:dry_run] = true }
  op.on('-v', '--verbose', 'Provide more information during run') { options[:verbose] = true }
  op.on('-p', '--prune', 'Delete all files in test that do not exist in Prod') { options[:prune] = true }
  op.on('-f', '--force', 'ignore warnings that may prevent completion') { options[:force] = true }
  op.on('-t', '--file-type EXT', 'File extension to deploy (default: .html)') { |v| options[:file_type] = v.start_with?('.') ? v.downcase : ".#{v.downcase}" }
  op.on('-h', '--help', 'Show help/usage') { puts op; exit }
end.parse!

SRC    = options[:src_dir]
DST    = options[:dst_dir]
BACKUP  = options[:backup_dir]
FTYPE   = options[:file_type] ||= ".rb"
DRY     = options[:dry]
VERBOSE = options[:verbose]
PRUNE   = options[:prune]
FORCE   = options[:force]

abort "Source #{SRC} does not exist" unless Dir.exist?(SRC)
abort "Destination #{DST} does not exist" unless Dir.exist?(DST)

real_prod = File.realpath(SRC)
real_test = File.realpath(DST)

if real_prod == real_test
  abort 'data collision detected'
end
if real_test.start_with?(real_prod + File::SEPARATOR)
  abort 'data overlap detected'
end
def collect_files(base)
  rels = []
    Find.find(base) do |path|
      next if File.directory?(path)
      next unless path.downcase.end_with?(FTYPE)
      rel = path.sub(/^#{Regexp.escape(base)}\//, '')
      rels << rel
   end
  rels
end

src_files = collect_files(SRC)
dst_files = collect_files(DST)

stamp = Time.now.strftime('%Y-%m-%d_%H%M%S')
backup_dir = File.join(BACKUP, stamp)
backup_prod = File.join(backup_dir, 'src_before')
backup_test = File.join(backup_dir, 'dst_before')

puts "Backup root #{BACKUP}"
puts " Creating backup at #{backup_dir}"
unless DRY
  FileUtils.mkdir_p backup_prod
  FileUtils.mkdir_p backup_test
end

src_files.each do |rel|
  src = File.join(SRC, rel)
  dst = File.join(backup_prod, rel)
  puts "  ↳ backup prod: #{rel}" if VERBOSE
  unless DRY
    FileUtils.mkdir_p File.dirname(dst)
    FileUtils.cp src, dst, preserve: true
  end
end

dst_files.each do |rel|
  src = File.join(DST, rel)
  dst = File.join(backup_test, rel)
  puts "  ↳ backup test: #{rel}" if VERBOSE
  unless DRY
    FileUtils.mkdir_p File.dirname(dst)
    FileUtils.cp src, dst, preserve: true
  end
end

unless DRY
  FileUtils.mkdir_p backup_dir
  File.write(File.join(backup_dir, 'MANIFEST.txt'), <<~MAN)
    Deploy manifest — #{Time.now}
    Source:      #{SRC}
    Destination: #{DST}
    Backup:      #{backup_dir}
    Files(code): #{src_files.size}
    Files(site): #{dst_files.size}
    Options:     prune=#{PRUNE} force=#{FORCE}
  MAN
end

# Decide what to copy
copied = []
skipped = []

src_files.each do |rel|
  src = File.join(SRC, rel)
  dst = File.join(DST, rel)
  do_copy = false
  if FORCE || !File.exist?(dst)
    do_copy = true
  else
    src_stat = File.stat(src)
    dst_stat = File.stat(dst) rescue nil
    do_copy = true if dst_stat.nil?
    if dst_stat
      do_copy ||= (src_stat.size != dst_stat.size) || (src_stat.mtime > dst_stat.mtime)
    end
  end

  if do_copy
    puts "→ copy: #{rel}"
    unless DRY
      FileUtils.mkdir_p File.dirname(dst)
      FileUtils.cp src, dst, preserve: true
    end
    copied << rel
  else
    puts "· skip: #{rel}" if VERBOSE
    skipped << rel
  end
end

# Optional prune: remove .<filetype> files in DST that are not present in SRC
pruned = []
if PRUNE
  (dst_files - src_files).each do |rel|
    target = File.join(SITE, rel)
    puts "× prune: #{rel}"
    pruned << rel
    FileUtils.rm_f(target) unless DRY
    # Remove empty directories up the tree
    dir = File.dirname(target)
    while dir.start_with?(DST) && Dir.exist?(dir) && (Dir.children(dir).empty?)
      FileUtils.rmdir(dir) unless DRY
      dir = File.dirname(dir)
    end
  end
end

puts "\nSummary"
puts "  Copied:  #{copied.size} files"
puts "  Skipped: #{skipped.size} files"
puts "  Pruned:  #{pruned.size} files" if PRUNE
puts "  Backup:  #{backup_dir}"
puts DRY ? "(dry-run only; no changes made)" : "Done."


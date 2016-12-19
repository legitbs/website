require 'chronic'

prequals = <<EOF.lines
DEF CON CTF	team@legitbs.net	us	20-May-2016	7-Aug-2016	https://legitbs.net/
RuCTFE	irina@ructf.org	ru	12-Nov-2016	12-Nov-2016	https://ructfe.org
HITCON CTF	alan@hitcon.org	tw	8-Oct-2016	3-Dec-2016	http://ctf.hitcon.org
ccc ctf	robbje@aachen.ccc.de	de	27-Dec-2016	29-Dec-2016	https://33c3ctf.ccc.ac/announcements/
Boston Key Party	crowell@bu.edu	us	24-Feb-2017	25-Feb-2017	http://bostonkey.party
UCSB iCTF		us	3-Mar-2017	3-Mar-2017	https://ictf.cs.ucsb.edu/index.html
0ctf	0ops@0ops.net	cn	18-Mar-2017	31-jun-2017	https://ctf.0ops.net
PlaidCTF	plaid.parliament.of.pwning@gmail.com	us	21-Apr-2017	21-Apr-2017	https://twitter.com/PlaidCTF
EOF

prequals.each do |pq|
  cells = pq.strip.split("\t")
  name = cells[0]
  start = cells[3]
  finish = cells[4]
  website = cells[5]

  start_date = Chronic.parse(start).strftime('%B %-d, %Y')
  finish_date = Chronic.parse(finish).strftime('%B %-d, %Y')

  puts "%tr"
  puts "  %th"
  puts "    %a{href: '#{website}'} #{name}"
  puts "  %td #{start_date}"
  puts "  %td #{finish_date}"
  puts "  %td"
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Team.delete_all
Admin.delete_all
App.delete_all
Email.delete_all
Delivery.delete_all

# Came up with some names using https://www.name-generator.org.uk just in
# case anyone thinks these names resemble real people or businesses.
# As they say "Any resemblance to actual persons, living or dead,
# or actual events is purely coincidental"

# Smart Unlimited
smart_team = Team.create!
# Wu Industries
wu_team = Team.create!

smart_team.admins.create!([
  { email: "joy@smart-unlimited.com", password: "password", name: "Joy Rice" },
  { email: "taliyah@smart-unlimited.com", password: "password", name: "Taliyah Parsons" }
])

wu_team.admins.create!([
  { email: "liz@wu-industries.com", password: "password", name: "Lizzie Chan" }
])

acting_app = smart_team.apps.create!({ name: "Acting Twins" })
key_app = smart_team.apps.create!({ name: "Key Popping Street Artists" })
office_app = wu_team.apps.create!({ name: "Acting in My Office" })

address1 = Address.create!(text: "foo@bar.com")
address2 = Address.create!(text: "foo@example.com")

email = acting_app.emails.create!(
  from_address_id: address1.id,
  data: <<-EOF
From: foo@bar.com
To: foo@example.com
Subject: This is a test email
Date: Fri, 27 Jul 2018 03:39:25 +0000
Message-ID:
 <ME2PR01MB380900AFED51A53176641AC0B12A0@ME2PR01MB3809.ausprd01.prod.outlook.com>
Content-Type: multipart/related;
	boundary="_004_ME2PR01MB380900AFED51A53176641AC0B12A0ME2PR01MB3809ausp_";
	type="multipart/alternative"
MIME-Version: 1.0

--_004_ME2PR01MB380900AFED51A53176641AC0B12A0ME2PR01MB3809ausp_
Content-Type: multipart/alternative;
	boundary="_000_ME2PR01MB380900AFED51A53176641AC0B12A0ME2PR01MB3809ausp_"

--_000_ME2PR01MB380900AFED51A53176641AC0B12A0ME2PR01MB3809ausp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello,

This is a test email. Isn't it exciting?

https://foo.com

--_000_ME2PR01MB380900AFED51A53176641AC0B12A0ME2PR01MB3809ausp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<p>Hello,</p>
<p>This is a test email. Isn't it exciting?</p>
<p><a href="https://foo.com">foo.com</a></p>

--_000_ME2PR01MB380900AFED51A53176641AC0B12A0ME2PR01MB3809ausp_--

  EOF
)

delivery = email.deliveries.create!(address_id: address2.id, sent: true)

PostfixLogLine.create!(
  delivery_id: delivery.id,
  time: DateTime.now,
  dsn: "2.0.0",
  extended_status: "sent (250 2.0.0 OK 1532723670 f21-v6si4784194plj.180 - gsmtp)",
  # We don't show the values below in the UI
  relay: "",
  delay: "",
  delays: ""
)

delivery.open_events.create!(
  user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 11_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E302",
  ip: "1.1.1.1"
)

link = Link.create!(url: "https://foo.com")

delivery_link = delivery.delivery_links.create!(link_id: link.id)

delivery_link.click_events.create!(
  user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 11_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E302",
  ip: "1.1.1.1"
)

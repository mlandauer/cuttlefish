# frozen_string_literal: true

require "spec_helper"

describe "deliveries/show.json.erb", type: :view do
  it do
    app = create(
      :app,
      id: 2,
      name: "Planning Alerts",
      # Not putting a custom tracking domain in so that we don't have to deal
      # with the DNS validation failing
      from_domain: "planningalerts.org.au"
    )
    from_address = create(
      :address,
      id: 12,
      text: "bounces@planningalerts.org.au"
    )
    to_address = create(
      :address,
      id: 13,
      text: "foo@gmail.com"
    )
    email = create(
      :email,
      id: 1753541,
      from_address: from_address,
      app: app,
      ignore_deny_list: false
    )
    # Updating this way to ignore model callbacks
    email.update_columns(
      message_id: "538ef46757549_443e4bb0f901893332@kedumba.mail",
      subject: "1 new planning application",
      data_hash: "aa126db79482378ce17b441347926570228f12ef"
    )

    link1 = create(
      :link,
      id: 123,
      url: "http://www.planningalerts.org.au/alerts/abc1234/area"
    )
    link2 = create(
      :link,
      id: 321,
      url: "http://www.planningalerts.org.au/alerts/abc1234/unsubscribe"
    )
    delivery_link1 = create(
      :delivery_link,
      link: link1
    )
    click_event = create(
      :click_event,
      user_agent: "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:24.0) " \
                  "Gecko/20100101 Firefox/24.0",
      ip: "1.2.3.4",
      referer: nil,
      created_at: "2014-06-04T20:33:53.000+10:00"
    )
    delivery_link2 = create(
      :delivery_link,
      link: link2,
      click_events: [click_event]
    )
    open_event = create(
      :open_event,
      user_agent: "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.7) " \
                  "Gecko/2009021910 Firefox/3.0.7 " \
                  "(via ggpht.com GoogleImageProxy)",
      ip: "2.3.4.5",
      created_at: "2014-10-06T16:05:52.000+11:00"
    )
    postfix_log_line = create(
      :postfix_log_line,
      time: "2014-06-04T20:26:53.000+10:00",
      relay: "gmail-smtp-in.l.google.com[173.194.79.26]:25",
      delay: "1.7",
      delays: "0.05/0/0.58/1",
      dsn: "2.0.0",
      extended_status:
        "sent (250 2.0.0 OK 1401877617 bh2si4687161pbb.204 - gsmtp)"
    )
    delivery = create(
      :delivery,
      id: 5,
      email: email,
      address: to_address,
      created_at: "2014-06-04T20:26:51.000+10:00",
      updated_at: "2014-06-04T20:26:55.000+10:00",
      sent: true,
      status: "delivered",
      open_tracked: true,
      delivery_links: [delivery_link1, delivery_link2],
      open_events: [open_event],
      postfix_log_lines: [postfix_log_line],
      postfix_queue_id: "38B72370AC41"
    )
    create(:meta_value, email: email, key: "foo", value: "bar")
    create(:meta_value, email: email, key: "wibble", value: "wobble")

    assign(:delivery, delivery)
    render

    expect(JSON.parse(rendered, symbolize_names: true)).to eq(
      id: 5,
      from_address: {
        id: 12,
        text: "bounces@planningalerts.org.au"
      },
      to_address: {
        id: 13,
        text: "foo@gmail.com"
      },
      subject: "1 new planning application",
      sent: true,
      status: "delivered",
      message_id: "538ef46757549_443e4bb0f901893332@kedumba.mail",
      email_id: 1753541,
      data_hash: "aa126db79482378ce17b441347926570228f12ef",
      created_at: "2014-06-04T20:26:51.000+10:00",
      updated_at: "2014-06-04T20:26:55.000+10:00",
      ignore_deny_list: false,
      app: {
        id: 2,
        name: "Planning Alerts",
        # custom_tracking_domain: "email.planningalerts.org.au",
        custom_tracking_domain: nil,
        from_domain: "planningalerts.org.au"
      },
      tracking: {
        open_tracked: true,
        open_events: [
          {
            user_agent:
              "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.7) " \
              "Gecko/2009021910 Firefox/3.0.7 (via ggpht.com GoogleImageProxy)",
            referer: nil,
            ip: "2.3.4.5",
            created_at: "2014-10-06T16:05:52.000+11:00"
          }
        ],
        links: [
          {
            id: 123,
            url: "http://www.planningalerts.org.au/alerts/abc1234/area",
            click_events: []
          },
          {
            id: 321,
            url: "http://www.planningalerts.org.au/alerts/abc1234/unsubscribe",
            click_events: [
              {
                user_agent: "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:24.0) " \
                            "Gecko/20100101 Firefox/24.0",
                referer: nil,
                ip: "1.2.3.4",
                created_at: "2014-06-04T20:33:53.000+10:00"
              }
            ]
          }
        ],
        postfix_queue_id: "38B72370AC41",
        postfix_log_lines: [
          {
            time: "2014-06-04T20:26:53.000+10:00",
            relay: "gmail-smtp-in.l.google.com[173.194.79.26]:25",
            delay: "1.7",
            delays: "0.05/0/0.58/1",
            dsn: "2.0.0",
            extended_status:
              "sent (250 2.0.0 OK 1401877617 bh2si4687161pbb.204 - gsmtp)"
          }
        ]
      },
      meta_values: {
        foo: "bar",
        wibble: "wobble"
      }
    )
  end
end

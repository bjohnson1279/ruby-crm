# db/seeds.rb

ActiveRecord::Base.transaction do
  puts "Seeding Apex Financial CRM..."

  # 1. Create Firm
  firm = Firm.create!(name: "Apex Wealth Advisors")

  # 2. Create Users
  user1 = User.create!(firm: firm, name: "Sarah Jenkins", email: "sarah@apexwealth.com")
  user2 = User.create!(firm: firm, name: "Marcus Brody", email: "marcus@apexwealth.com")

  # Set current context for tenant-scoped commands
  Current.firm = firm
  Current.user = user1

  # 3. Create Account Types
  ira = Accounts::AccountType.create!(firm: firm, name: "Traditional IRA")
  roth = Accounts::AccountType.create!(firm: firm, name: "Roth IRA")
  brokerage = Accounts::AccountType.create!(firm: firm, name: "Individual Brokerage")
  joint = Accounts::AccountType.create!(firm: firm, name: "Joint Tenants WROS")

  # 4. Create Households
  hh_smith = Contacts::CreateHousehold.call(firm: firm, actor: user1, params: { name: "Smith Family Trust" })
  hh_vander = Contacts::CreateHousehold.call(firm: firm, actor: user1, params: { name: "Vanderbilt Wealth Estate" })
  hh_oconnor = Contacts::CreateHousehold.call(firm: firm, actor: user1, params: { name: "O'Connor Holdings" })

  # 5. Create Contacts (10 contacts)
  # Smith family
  smith_john = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "John", last_name: "Smith", email: "john.smith@gmail.com", date_of_birth: "1968-05-12" })
  smith_jane = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "Jane", last_name: "Smith", email: "jane.smith@gmail.com", date_of_birth: "1970-11-23" })
  smith_billy = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "Billy", last_name: "Smith", email: "billy.smith@gmail.com", date_of_birth: "2002-04-15" })

  # Vanderbilt family
  vander_gloria = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "Gloria", last_name: "Vanderbilt", email: "gloria@vanderbilt.org", date_of_birth: "1942-02-20" })
  vander_anderson = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "Anderson", last_name: "Vanderbilt", email: "anderson.v@vanderbilt.org", date_of_birth: "1967-06-03" })

  # O'Connor family
  oconnor_liam = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "Liam", last_name: "O'Connor", email: "liam@oconnor.ie", date_of_birth: "1975-09-08" })
  oconnor_fiona = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "Fiona", last_name: "O'Connor", email: "fiona@oconnor.ie", date_of_birth: "1980-01-30" })

  # Independent contacts (no household membership, to test integrity warning)
  miller_david = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "David", last_name: "Miller", email: "david.miller@independent.com", date_of_birth: "1985-07-14" })
  davis_sarah = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "Sarah", last_name: "Davis", email: "sarah.davis@independent.com", date_of_birth: "1990-12-05" })
  wilson_james = Contacts::CreateContact.call(firm: firm, actor: user1, params: { first_name: "James", last_name: "Wilson", email: "james.wilson@independent.com", date_of_birth: "1955-03-22" })

  # 6. Establish Household Memberships and Primary Contacts
  # Smith memberships
  Contacts::LinkContactToHousehold.call(firm: firm, actor: user1, household: hh_smith, contact: smith_john, role: "primary")
  Contacts::LinkContactToHousehold.call(firm: firm, actor: user1, household: hh_smith, contact: smith_jane, role: "spouse")
  Contacts::LinkContactToHousehold.call(firm: firm, actor: user1, household: hh_smith, contact: smith_billy, role: "child")
  hh_smith.update!(primary_contact_id: smith_john.id)

  # Vanderbilt memberships
  Contacts::LinkContactToHousehold.call(firm: firm, actor: user1, household: hh_vander, contact: vander_gloria, role: "primary")
  Contacts::LinkContactToHousehold.call(firm: firm, actor: user1, household: hh_vander, contact: vander_anderson, role: "child")
  hh_vander.update!(primary_contact_id: vander_gloria.id)

  # O'Connor memberships
  # Intentional Violation: O'Connor household has Fiona as spouse, but NO primary member, triggering "Households Without Primary" alert!
  Contacts::LinkContactToHousehold.call(firm: firm, actor: user1, household: hh_oconnor, contact: oconnor_liam, role: "spouse")
  Contacts::LinkContactToHousehold.call(firm: firm, actor: user1, household: hh_oconnor, contact: oconnor_fiona, role: "child")
  # primary_contact_id left nil!

  # 7. Create Relationships
  Contacts::Relationship.create!(firm: firm, contact: smith_john, related_contact: smith_jane, relationship_type: "spouse")
  Contacts::Relationship.create!(firm: firm, contact: smith_jane, related_contact: smith_john, relationship_type: "spouse")
  Contacts::Relationship.create!(firm: firm, contact: smith_john, related_contact: smith_billy, relationship_type: "child")
  Contacts::Relationship.create!(firm: firm, contact: vander_gloria, related_contact: vander_anderson, relationship_type: "child")

  # 8. Create Accounts and Holdings (~15 accounts)
  accounts_data = [
    { contact: smith_john, household: hh_smith, type: ira, number: "IRA-5512", custodian: "Schwab" },
    { contact: smith_john, household: hh_smith, type: brokerage, number: "BRK-9901", custodian: "Schwab" },
    { contact: smith_jane, household: hh_smith, type: roth, number: "ROT-4122", custodian: "Fidelity" },
    { contact: smith_john, household: hh_smith, type: joint, number: "JNT-3301", custodian: "Fidelity" },
    { contact: vander_gloria, household: hh_vander, type: brokerage, number: "VAND-001", custodian: "Merrill Lynch" },
    { contact: vander_gloria, household: hh_vander, type: ira, number: "VAND-002", custodian: "Merrill Lynch" },
    { contact: vander_anderson, household: hh_vander, type: roth, number: "AND-991", custodian: "Schwab" },
    { contact: oconnor_liam, household: hh_oconnor, type: ira, number: "OC-IRA-1", custodian: "Schwab" },
    { contact: oconnor_fiona, household: hh_oconnor, type: brokerage, number: "OC-BRK-2", custodian: "Fidelity" },
    # Independent accounts
    { contact: miller_david, household: hh_smith, type: brokerage, number: "MIL-889", custodian: "Schwab" }, # Intentional Violation: Owner contact (Miller) is NOT member of linked household (Smith), triggering "Orphaned Account"!
    { contact: davis_sarah, household: hh_vander, type: roth, number: "DAV-771", custodian: "Fidelity" }, # Intentional Violation: Owner contact (Davis) is NOT member of linked household (Vanderbilt)
    { contact: wilson_james, household: hh_oconnor, type: brokerage, number: "WIL-332", custodian: "Schwab" } # Intentional Violation: Owner contact (Wilson) is NOT member of linked household (O'Connor)
  ]

  # Seed accounts and holdings
  accounts_data.each_with_index do |data, index|
    acc = Accounts::CreateInvestmentAccount.call(
      firm: firm,
      actor: user1,
      params: {
        contact: data[:contact],
        household: data[:household],
        account_type: data[:type],
        account_number: data[:number],
        custodian: data[:custodian],
        status: "active",
        current_value: 0
      }
    )

    # Import holdings to automatically set account values
    holdings_list = [
      { symbol: "VTI", description: "Vanguard Total Stock ETF", quantity: (10 + index * 5), market_value: (2500.0 * (index + 1)), as_of_date: Date.current },
      { symbol: "BND", description: "Vanguard Total Bond ETF", quantity: (5 + index * 2), market_value: (1200.0 * (index + 1)), as_of_date: Date.current }
    ]

    # Add stale holding for Anderson to trigger stale holdings check
    if data[:contact] == vander_anderson
      holdings_list << { symbol: "AAPL", description: "Apple Inc.", quantity: 15, market_value: 3000.0, as_of_date: 10.days.ago.to_date }
    end

    Accounts::ImportHoldings.call(
      firm: firm,
      actor: user1,
      account: acc,
      holdings_data: holdings_list
    )

    # 9. Intentional Violation: AUM Drift on the first account
    if index == 0
      # Directly update database using raw SQL to bypass callbacks and triggers
      ActiveRecord::Base.connection.execute(
        "UPDATE investment_accounts SET current_value = current_value + 15000.00 WHERE id = #{acc.id}"
      )
    end
  end

  # 10. Create Sample Tasks
  Tasks::CreateTask.call(
    firm: firm,
    actor: user1,
    params: {
      assigned_user: user1,
      contact: smith_john,
      subject: "Annual Review Meeting",
      description: "Prepare annual performance report and check asset allocation drift.",
      due_date: 3.days.from_now.to_date,
      priority: "high"
    }
  )

  task_to_complete = Tasks::CreateTask.call(
    firm: firm,
    actor: user1,
    params: {
      assigned_user: user2,
      contact: vander_gloria,
      subject: "Sign Advisory Agreement",
      description: "Follow up on outstanding trust documents and advisory contract signature.",
      due_date: Date.yesterday,
      priority: "medium"
    }
  )
  Tasks::CompleteTask.call(firm: firm, actor: user2, task: task_to_complete)

  Tasks::CreateTask.call(
    firm: firm,
    actor: user1,
    params: {
      assigned_user: user2,
      contact: oconnor_liam,
      subject: "Rollover Paperwork Setup",
      description: "Process Schwab Traditional IRA rollover documentation.",
      due_date: 10.days.from_now.to_date,
      priority: "medium"
    }
  )

  # 11. Create Sample Notes
  Contacts::CreateNote.call(
    firm: firm,
    actor: user1,
    params: {
      contact: smith_john,
      body: "Called client to discuss recent market volatility. Client requested to keep asset allocation unchanged.",
      category: "call"
    }
  )

  Contacts::CreateNote.call(
    firm: firm,
    actor: user2,
    params: {
      contact: vander_gloria,
      body: "Met in office to review Vanderbilt Estate trust documents. Signed updated discretionary advisory agreements.",
      category: "meeting"
    }
  )

  # 12. Create Sample Calendar Events
  Calendar::CreateEvent.call(
    firm: firm,
    actor: user1,
    params: {
      contact: smith_john,
      title: "Annual Financial Plan Review",
      description: "Review comprehensive retirement roadmap and educational funding accounts.",
      start_at: 2.days.from_now.beginning_of_day + 10.hours,
      end_at: 2.days.from_now.beginning_of_day + 11.hours + 30.minutes,
      color: "green"
    }
  )

  Calendar::CreateEvent.call(
    firm: firm,
    actor: user1,
    params: {
      contact: vander_gloria,
      title: "Estate Plan Coordination",
      description: "Discuss legacy transfer structures with trust attorneys.",
      start_at: 5.days.from_now.beginning_of_day + 14.hours,
      end_at: 5.days.from_now.beginning_of_day + 15.hours + 30.minutes,
      color: "purple"
    }
  )

  Calendar::CreateEvent.call(
    firm: firm,
    actor: user2,
    params: {
      title: "Weekly Advisory Team Sync",
      description: "Internal firm operations and client service workflow reviews.",
      start_at: 1.day.from_now.beginning_of_day + 9.hours,
      end_at: 1.day.from_now.beginning_of_day + 10.hours,
      color: "blue"
    }
  )

  puts "Seeding completed successfully!"
  puts "- Created Firm: #{firm.name}"
  puts "- Created Users: #{User.count}"
  puts "- Created Households: #{Contacts::Household.count}"
  puts "- Created Contacts: #{Contacts::Contact.count}"
  puts "- Created Investment Accounts: #{Accounts::InvestmentAccount.count}"
  puts "- Created Holdings: #{Accounts::Holding.count}"
  puts "- Created Audit Trail Log Events: #{Compliance::AuditEvent.count}"
end

Foresight.PatientView = Backbone.View.extend(
  initialize: ->
    Foresight.bus.bind('patientid:change', (id) =>
      @onPatientChange(id)
    )
  onPatientChange: (value = '') ->
    value = value.trim()
    @render(null)
    if value
      $.ajax(
        data:
          group: true
          key: """ "#{value}" """
        url: '/kujua/_design/kujua-foresight/_view/registrations'
        complete: (response) =>
          rows = JSON.parse(response.responseText)?.rows
          @render(rows?[0], value)
          @validate()
      )
  render: (row, patient_id = false) ->
    @patient = row?.value
    if @patient
      @$el.html("""
        <div class="container">
          <div class="row">
            <div class="span6">
              <span class="label label-success">#{patient_id}</span>
              <span class="label label-info">#{@patient.patient_name}</span>
              <span class="label">#{@patient.phone}</span>
            </div>
          </div>
          <div class="row">
            <div class="span3">
              #{@lastMessage()}
            </div>
            <div class="span3">
              #{@nextMessage()}
            </div>
          </div>
        </div>
      """)
    else if patient_id
      @$el.html("""
        <span class="label">Patient with ID '#{patient_id}' not found</span>
      """)
    else
      @$el.html("""
        <span class="label">Searching ...</span>
      """)
    @
  nextMessage: ->
    msg = @patient.next_message
    if msg
      """
        <div class="message">
          <div class="label label-info">
            <i class="icon-bolt"></i>
            Scheduled Message
          </div>
          <span class="label label-info">#{Foresight.formatDate(msg.due)}</span>
          #{msg.messages[0].message}
        </div>
      """
    else
      """
        <div class="message">
          <div class="label label-info">
            <i class="icon-bolt"></i>
            No scheduled messages
          </div>
        </div>
      """
  lastMessage: ->
    msg = @patient.last_message
    if msg
      """
        <div class="message">
          <div class="label label-success">
            <i class="icon-envelope"></i>
            Last Message
          </div>
          <span class="label label-info">#{Foresight.formatDate(msg.timestamp)}</span>
          #{msg.messages[0].message}
        </div>
      """
    else
      """
        <div class="message">
          <div class="label label-success">
            <i class="icon-envelope"></i>
            No delivered messages
          </div>
        </div>
      """
  className: 'patient span6'
)

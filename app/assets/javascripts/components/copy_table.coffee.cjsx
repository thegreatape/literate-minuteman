@CopyTable = React.createClass
  render: ->
    <table className="table table-condensed">
      <thead>
        <tr>
          <th>Title</th>
          <th>Status</th>
          <th>Location</th>
          <th>Call Number</th>
          <th>Synced At</th>
        </tr>
      </thead>
      <tbody>
        { <CopyRow copy={copy} /> for copy in @props.copies }
      </tbody>
    </table>


CopyRow = React.createClass
  render: ->
    if @props.copy.url
      title = (<a href={@props.copy.url}>
          {@props.copy.title}
        </a>)
    else
      title = <span>{@props.copy.title}</span>

    <tr className="copy">
      <td data-title="Title"> {title} </td>
      <td data-title="Status">{@props.copy.status}</td>
      <td data-title="Location">{@props.copy.location_name}</td>
      <td data-title="Call Number">{@props.copy.call_number}</td>
      <td am-time-ago={@props.copy.last_synced_at} data-title="Last Synced At"></td>
    </tr>

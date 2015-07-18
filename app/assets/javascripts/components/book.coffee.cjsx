@Book = React.createClass
  render: ->
    <div className="book-result">
      <div className="row book-data">
        <div className="col-lg-1 col-md-1 col-sm-2 col-xs-3">
          <a href={@props.book.goodreads_link}>
            <img className="book-image" src={ @props.book.image_url } />
          </a>
        </div>
        <div className="col-lg-11 col-md-11 col-sm-10 col-xs-9">
          <a className="title" href={@props.book.goodreads_link}>
            { @props.book.title }
          </a>
          <div className="author">
            { @props.book.author }
          </div>
          <a className="book-toggle btn btn-default" href="#" ng-click="book.showCopies = !book.showCopies">
            <span count="(book.copies | filter:copyFilter).length" ng-pluralize="<%= true %>" ng-show="!book.showCopies" when="{'1': 'Show 1 Copy', 'other': 'Show { %> Copies' %>"></span>
            <span ng-show="book.showCopies">
              Hide Copies
            </span>
          </a>
        </div>
        <CopyTable copies={@props.book.copies} />
      </div>
    </div>

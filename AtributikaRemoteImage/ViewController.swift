//
//  ViewController.swift
//  AtributikaRemoteImage
//
//  Created by Tarun Sharma on 13/02/25.
//

import Atributika
import AtributikaViews
import UIKit

// MARK: - CellType

enum CellType {
  case tweetWithAttributedLabel
  case tweetWithUILabel
}

var cellToUse: CellType = .tweetWithAttributedLabel

var tweets = [
  """
  <img url="https://fastly.picsum.photos/id/1037/20/20.jpg?hmac=H1FupXbPg3p-Qx6RtuTkKa0FDn9avljHu6vqOGlhgXY"/> This image is loaded from remote URL
  Check this <a href=\"https://github.com/psharanda/Atributika\">link</a>
  """,
]

// MARK: - ViewController

class ViewController: UIViewController {

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: CGRect(), style: .plain)

    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 50
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Attributika"
    view.addSubview(tableView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
}

// MARK: ViewController + UITableViewDelegate, UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    tweets.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellId = "CellId"
    let cell: UITableViewCell & TweetContainingCell = switch cellToUse {
      case .tweetWithAttributedLabel:
        (tableView.dequeueReusableCell(withIdentifier: cellId) as? TweetCell) ?? TweetCell(
          style: .default,
          reuseIdentifier: cellId
        )
      case .tweetWithUILabel:
        (tableView.dequeueReusableCell(withIdentifier: cellId) as? TweetCellWithLabel) ?? TweetCellWithLabel(
          style: .default,
          reuseIdentifier: cellId
        )
    }

    cell.tweet = tweets[indexPath.row]
    return cell
  }

  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    tableView.flashScrollIndicators()

    if let selectedRow = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedRow, animated: animated)
    }
  }
}

// MARK: - TweetContainingCell

protocol TweetContainingCell: AnyObject {
  var tweet: String? { get set }
}

// MARK: - TweetCell

class TweetCell: UITableViewCell, TweetContainingCell {
  private var tweetLabel: AttributedLabel!

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupAttributedLabel()
  }

  func setupAttributedLabel() {
    tweetLabel = AttributedLabel()
    tweetLabel.onLinkTouchUpInside = { _, val in
      if let linkStr = val as? String {
        if let url = URL(string: linkStr) {
          UIApplication.shared.open(url)
        }
      }
    }

    contentView.addSubview(tweetLabel)

    let marginGuide = contentView.layoutMarginsGuide

    tweetLabel.translatesAutoresizingMaskIntoConstraints = false
    tweetLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    tweetLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
    tweetLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    tweetLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
    // tweetLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true

    tweetLabel.numberOfLines = 0
    tweetLabel.font = .preferredFont(forTextStyle: .body)
    // tweetLabel.highlightedLinkAttributes = Attrs().underlineStyle(.single).attributes
    tweetLabel.disabledLinkAttributes = Attrs().foregroundColor(.lightGray).attributes
    tweetLabel.linkHighlightViewFactory = RoundedRectLinkHighlightViewFactory()

    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
    tweetLabel.addGestureRecognizer(lpgr)
  }

  @objc
  private func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
    if sender.state == .began,
       let linkValue = tweetLabel.highlightedLinkValue,
       let link = linkValue as? String {
      let ac = UIAlertController(title: "Link", message: link, preferredStyle: .actionSheet)
      ac.addAction(UIAlertAction(title: "Copy", style: .default, handler: { _ in

      }))
      ac.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in

      }))
      ac.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in

      }))
      ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      ac.popoverPresentationController?.sourceView = self
      window?.rootViewController?.present(ac, animated: true)
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var tweet: String? {
    didSet {
      guard let tweet else {
        return
      }

      tweetLabel.attributedText = tweet.styleAsTweet(labelView: tweetLabel)
    }
  }

  func relayout() {
    tweetLabel.setNeedsDisplay()
//    tweetLabel.setNeedsLayout()
//    tweetLabel.attributedText = tweetLabel.attributedText
//    tweetLabel.setNeedsDisplayText(changedGeometry: true) // Need to expose it in library

  }
}

// MARK: - TweetCellWithLabel

class TweetCellWithLabel: UITableViewCell, TweetContainingCell {
  private var tweetLabel: UILabel!

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupAttributedLabel()
  }

  func setupAttributedLabel() {
    tweetLabel = UILabel()

    contentView.addSubview(tweetLabel)

    let marginGuide = contentView.layoutMarginsGuide

    tweetLabel.translatesAutoresizingMaskIntoConstraints = false
    tweetLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    tweetLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
    tweetLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    tweetLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

    tweetLabel.numberOfLines = 0
    tweetLabel.font = .preferredFont(forTextStyle: .body)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var tweet: String? {
    didSet {
      guard let tweet else {
        return
      }

      tweetLabel.attributedText = tweet.styleAsTweet(labelView: tweetLabel)
    }
  }
}

extension String {
  func styleAsTweet(labelView: UIView) -> NSAttributedString {

    let baseLinkAttrs = Attrs().foregroundColor(.red)

    let a = TagTuner {
      Attrs(baseLinkAttrs).akaLink($0.tag.attributes["href"] ?? "")
    }

    let img = TagTuner(
      style: {
        if let imageId = $0.tag.attributes["id"] {
          let textAttachment = NSTextAttachment()
          textAttachment.image = UIImage(named: imageId)
          return Attrs(baseLinkAttrs).attachment(textAttachment)
        } else if let url = URL(string: $0.tag.attributes["url"] ?? $0.tag.attributes["src"]) {
          let attachment = RemoteImageTextAttachment(
            imageURL: url,
            label: labelView,
            fitInside: CGRect(x: 0, y: -4, width: 20, height: 20)
          )
          return Attrs(baseLinkAttrs).attachment(attachment)
        } else {
          return Attrs(baseLinkAttrs)
        }
      },
      transform: { _, part in
        switch part {
          case .opening:
            "\u{FFFC}"
          case .closing:
            nil
          case .content:
            nil
        }
      }
    )

    let link = DetectionTuner {
      // ignore detection if akaLink was set for its range beforehand
      if $0.firstExistingAttributeValue(for: .akaLink) != nil {
        Attrs()
      } else {
        Attrs(baseLinkAttrs).akaLink($0.text)
      }
    }

    return self
      .style(tags: ["a": a, "img": img])
      .styleLinks(link)
      .attributedString
  }
}

extension URL {
  init?(string: String?) {
    guard let string else {
      return nil
    }
    self.init(string: string)
  }
}

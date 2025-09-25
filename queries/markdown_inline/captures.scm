(image 
  (image_description) @image.description 
  (link_destination) @image.destination
  (link_title)? @image.title) @image

(inline_link
  (link_text) @link.text
  (link_destination) @link.destination
  (link_title)? @link.title) @link

(shortcut_link
  (link_text) @shortcut.text) @shortcut

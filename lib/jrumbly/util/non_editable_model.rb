require 'java'

java_import 'javax.swing.table.DefaultTableModel'

class NonEditableModel < DefaultTableModel
  def is_cell_editable(row, col)
    false
  end
  def isCellEditable(row, col)
    false
  end
end

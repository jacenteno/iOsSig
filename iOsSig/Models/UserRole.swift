import Foundation

enum AppUserRole: String, CaseIterable, Codable {
    case ROL_0
    case ROL_1
    case ROL_2
    case ROL_3
    case ROL_4

    var permissions: Set<String> {
        switch self {
        case .ROL_0:
            return Set([
                "VIEW_HOME",
                "VIEW_PRODUCTS"
            ])
        case .ROL_1:
            return Set([
                "VIEW_HOME",
                "VIEW_PRODUCTS",
                "VIEW_SALES",
                "VIEW_COSTO",
                "VIEW_INVENTARIO",
                "VIEW_SALE_PRICES",
                "VIEW_PURCHASES",
                "VIEW_PEDIDOS",
                "VIEW_OFFLINE",
                "PRINT_LABELS"
            ])
        case .ROL_2:
            return Set([
                "VIEW_HOME",
                "VIEW_PRODUCTS",
                "VIEW_SALE_PRICES",
                "VIEW_SALES",
                "VIEW_OFFLINE",
                "VIEW_PURCHASES",
                "VIEW_PEDIDOS",
                "PRINT_LABELS"
            ])
        case .ROL_3:
            return Set([
                "VIEW_HOME",
                "VIEW_DASHBOARD",
                "VIEW_PRODUCTS",
                "VIEW_SALE_PRICES",
                "EDIT_PRICES",
                "FULL_ACCESS",
                "VIEW_CLIENTS",
                "VIEW_DAVID",
                "VIEW_FRONTERA",
                "VIEW_SALES",
                "VIEW_PURCHASES",
                "PRINT_LABELS",
                "EDIT_LABEL_FORMATS",
                "VIEW_COSTO",
                "VIEW_INVENTARIO",
                "VIEW_OFFLINE",
                "VIEW_PEDIDOS"
                
            ])
        case .ROL_4:
            return Set([
                "VIEW_HOME",
                "VIEW_FRONTERA"
            ])
        }
    }

    func hasPermission(_ permission: String) -> Bool {
        return permissions.contains(permission)
    }

    func hasFullAccess() -> Bool {
        return permissions.contains("FULL_ACCESS")
    }
}

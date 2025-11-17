import CoreData
import Foundation

@objc(ProductEntity)
public class ProductEntity: NSManagedObject {

}

extension ProductEntity {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductEntity> {
    return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
  }

  @NSManaged public var codproducto: String?
  @NSManaged public var desproducto: String?
  @NSManaged public var codigobarra: String?
  @NSManaged public var preciodeventa: Double
  @NSManaged public var existencias: Double
  @NSManaged public var ultcosto: Double
  @NSManaged public var referencia: String?
  @NSManaged public var nombre_departamento: String?
  @NSManaged public var codbodega: String?

}

extension ProductEntity: Identifiable {

}

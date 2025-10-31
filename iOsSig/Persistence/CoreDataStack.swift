import Foundation
import CoreData
import os.log

class CoreDataStack {
    static let shared = CoreDataStack()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "CoreDataStack")

    private func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "ProductEntity"
        entity.managedObjectClassName = "ProductEntity"
        
        var properties = [NSAttributeDescription]()
        
        let codproductoAttr = NSAttributeDescription()
        codproductoAttr.name = "codproducto"
        codproductoAttr.attributeType = .stringAttributeType
        codproductoAttr.isOptional = true
        properties.append(codproductoAttr)
        
        let desproductoAttr = NSAttributeDescription()
        desproductoAttr.name = "desproducto"
        desproductoAttr.attributeType = .stringAttributeType
        desproductoAttr.isOptional = true
        properties.append(desproductoAttr)

        let codigobarraAttr = NSAttributeDescription()
        codigobarraAttr.name = "codigobarra"
        codigobarraAttr.attributeType = .stringAttributeType
        codigobarraAttr.isOptional = true
        properties.append(codigobarraAttr)

        let preciodeventaAttr = NSAttributeDescription()
        preciodeventaAttr.name = "preciodeventa"
        preciodeventaAttr.attributeType = .doubleAttributeType
        properties.append(preciodeventaAttr)

        let existenciasAttr = NSAttributeDescription()
        existenciasAttr.name = "existencias"
        existenciasAttr.attributeType = .doubleAttributeType
        properties.append(existenciasAttr)

        let ultcostoAttr = NSAttributeDescription()
        ultcostoAttr.name = "ultcosto"
        ultcostoAttr.attributeType = .doubleAttributeType
        properties.append(ultcostoAttr)

        let referenciaAttr = NSAttributeDescription()
        referenciaAttr.name = "referencia"
        referenciaAttr.attributeType = .stringAttributeType
        referenciaAttr.isOptional = true
        properties.append(referenciaAttr)

        let nombreDeptoAttr = NSAttributeDescription()
        nombreDeptoAttr.name = "nombre_departamento"
        nombreDeptoAttr.attributeType = .stringAttributeType
        nombreDeptoAttr.isOptional = true
        properties.append(nombreDeptoAttr)

        let codbodegaAttr = NSAttributeDescription()
        codbodegaAttr.name = "codbodega"
        codbodegaAttr.attributeType = .stringAttributeType
        codbodegaAttr.isOptional = true
        properties.append(codbodegaAttr)
        
        entity.properties = properties
        model.entities = [entity]
        
        return model
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let model = createManagedObjectModel()
        let container = NSPersistentContainer(name: "iOsSig", managedObjectModel: model)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext () {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
                logger.info("💾 Core Data context saved successfully.")
            } catch {
                let nserror = error as NSError
                logger.error("❌ Unresolved error saving Core Data context: \(nserror), \(nserror.userInfo)")
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
        // Función para buscar un producto por su código
    
        func fetchProduct(byCode code: String) -> ProductEntity? {
    
            let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
    
            logger.info("🔍 Fetching product from Core Data with trimmed code: \(trimmedCode)")
    
            let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
    
            request.predicate = NSPredicate(format: "codproducto == %@", trimmedCode)
    
            
    
            do {
    
                let results = try viewContext.fetch(request)
    
                if let product = results.first {
    
                    logger.info("✅ Found product in Core Data.")
    
                    return product
    
                } else {
    
                    logger.warning("⚠️ Product not found in Core Data.")
    
                    return nil
    
                }
    
            } catch {
    
                logger.error("❌ Error fetching product: \(error.localizedDescription)")
    
                return nil
    
            }
    
        }
    
        
    
        // Función para guardar o actualizar un producto
    
        func saveProduct(_ product: Product) {
    
            let code = product.codproducto?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "N/A"
    
            logger.info("💾 Saving product to Core Data with code: \(code)")
    
            let context = viewContext
    
            
    
            let entity = fetchProduct(byCode: code) ?? ProductEntity(context: context)
    
            
    
            entity.codproducto = product.codproducto?.trimmingCharacters(in: .whitespacesAndNewlines)
    
            entity.desproducto = product.desproducto
    
            entity.codigobarra = product.codigobarra?.trimmingCharacters(in: .whitespacesAndNewlines)
    
            entity.preciodeventa = product.preciodeventa ?? 0.0
    
            entity.existencias = product.existencias ?? 0.0
    
            entity.ultcosto = product.ultcosto ?? 0.0
    
            entity.referencia = product.referencia?.trimmingCharacters(in: .whitespacesAndNewlines)
    
            entity.nombre_departamento = product.nombre_departamento
    
            entity.codbodega = product.codbodega?.trimmingCharacters(in: .whitespacesAndNewlines)
    
            
    
            logger.info("👍 Product data mapped to entity. Saving context...")
    
            saveContext()
    
        }
}

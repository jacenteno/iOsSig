import Foundation

extension Product {
  init(from entity: ProductEntity) {
    self.codproducto = entity.codproducto
    self.desproducto = entity.desproducto
    self.codigobarra = entity.codigobarra
    self.preciodeventa = entity.preciodeventa
    self.existencias = entity.existencias
    self.ultcosto = entity.ultcosto
    self.referencia = entity.referencia
    self.nombre_departamento = entity.nombre_departamento
    self.codbodega = entity.codbodega

    // Properties not stored in Core Data are set to default values
    self.codcompania = nil
    self.coddep = nil
    self.detalle = nil
    self.codproveedor = nil
    self.ubicacion = nil
    self.ofertas = nil
    self.ucosto = nil
    self.costofob = nil
    self.indexproductos = nil
    self.costooriginal = nil
    self.fvencimiento = nil
    self.ctacontable = nil
    self.bloqueofacturacion = nil
    self.gravadoexecto = nil
    self.prcimpuestoventa = nil
    self.nombre_lista_precio = nil
    self.listas_de_precio = nil
    self.series_asociadas = nil
    self.codigo_consultado = nil
    self.lista_referencia = nil
  }
}

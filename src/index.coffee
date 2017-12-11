import Brief from './brief'
import init  from './init'

brief       = new Brief()
brief.Brief = Brief
brief.init  = init


export {
  Brief, init
}

export default brief

// -*- mode: d -*-
/*
 *       modelview.d
 *
 *       Copyright 2014 Antonio-Miguel Corbi Bellot <antonio.corbi@ua.es>
 *     
 *       This program is free software; you can redistribute it and/or modify
 *       it under the terms of the GNU  General Public License as published by
 *       the Free Software Foundation; either version 3 of the License, or
 *       (at your option) any later version.
 *     
 *       This program is distributed in the hope that it will be useful,
 *       but WITHOUT ANY WARRANTY; without even the implied warranty of
 *       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *       GNU General Public License for more details.
 *      
 *       You should have received a copy of the GNU General Public License
 *       along with this program; if not, write to the Free Software
 *       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *       MA 02110-1301, USA.
 */

/**
 * Base class and interface for supporting the MVC pattern.
 */
module mvc.modelview;

import mvc.set;

/**
 * Base class for all models
 */
public class Model {
  public this () {
    //m_vl = [];
    //_vs = Set!View();
  }

  public void add_view (View v) { 
    /*
    for (int i = 0; i < m_vl.length; i++)
      if (m_vl[i] == v) return;

    m_vl ~= v;
    */

    _vs ~= v;
    //v.set_model (this);
  }

  public void del_view (View v) { 
    _vs.remove(v);

    /*
    if (m_vl.length == 0)
      return;

    // locate v pos
    int pos = -1;
    for (int i = 0; i < m_vl.length; i++)
      if (m_vl[i] == v) {
        pos = i;
        break;
      }
    if (pos != -1) { // v found
      auto vaux = m_vl[0..pos];
      if (pos != m_vl.length)
        vaux ~= m_vl[pos+1..$];

      m_vl = vaux;
    }
    */

  }
  
  public void notify_views () {
    /*foreach (v ; m_vl) {
      v.update ();
      }*/

    foreach (v, val ; _vs) v.update ();
  }

  //-- Data ----------------------------------
  private View[] m_vl;
  private Set!View _vs;
}

/**
 * Interface to implement for all classes that want to show or modify
 * a model.
 */
public interface View {
  /**
   * The model has changed, the view must be updated.
   */
  public abstract void update ();

  /**
   * Change the model associated with this view.
   */
  public abstract void set_model (Model m);

  /**
   * The view has changed, the model must be updated.
   */
  public abstract void update_model (); 
}

#ifndef __HolderGUI
#define __HolderGUI

#include "nHolder.h"
#include "ui_holderGUI.h"


class holderGUI: public QMainWindow, private Ui::holderGUI {
    Q_OBJECT

public:
	Q_INVOKABLE holderGUI();
	

public slots:
    
    void on_actionOpen_triggered();
	void openFiles(QStringList fnames);
	void addPhys(nPhysD& my_phys);
	void delPhys(QObject* my_phys);

//    void addPan(nGenericPan* pan) {
//        panlist.push_back(pan);
//    }
//    
//    void delPan(nGenericPan* pan) {
//        panlist.removeAll(pan);
//    }

private:
//    QList<nGenericPan*> panlist;

};


#endif

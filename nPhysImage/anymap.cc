/*
 *
 *    Copyright (C) 2013 Alessandro Flacco, Tommaso Vinci All Rights Reserved
 * 
 *    This file is part of nPhysImage library.
 *
 *    nPhysImage is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU Lesser General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    nPhysImage is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public License
 *    along with neutrino.  If not, see <http://www.gnu.org/licenses/>.
 *
 *    Contact Information: 
 *	Alessandro Flacco <alessandro.flacco@polytechnique.edu>
 *	Tommaso Vinci <tommaso.vinci@polytechnique.edu>
 *
 */

#include "anymap.h"

// strip leading and trailing spaces (questa l'ho fregata)
std::string trim(const std::string& str,
                 const std::string& whitespace)
{
	size_t strBegin = str.find_first_not_of(whitespace);
    if (strBegin == std::string::npos)
        return ""; // no content

    size_t strEnd = str.find_last_not_of(whitespace);
    size_t strRange = strEnd - strBegin + 1;

    return str.substr(strBegin, strRange);
}

// stream output operator (questo e' semplice)
std::ostream & operator<< (std::ostream &lhs, struct anydata &rhs)
{ 
	if (rhs.is_d()) return lhs<<rhs.get_d(); 
	else if (rhs.is_i()) return lhs<<rhs.get_i(); 
	else if (rhs.is_vec()) return lhs<<rhs.get_str(); // qui passo direttamente a stringa
	else if (rhs.is_str()) return lhs<<rhs.get_str(); 
	else return lhs<<"(unknown)";
}

// stream input operator (questo e' un po' piu' bordellone)
// 
// regole:
// 1. conversione numero: se funziona, int, altrimenti, double
// 2. se e' della forma (:) e' un vettore (to be implemented)
// 3. altrimenti e' una stringa
std::istream & operator>> (std::istream &lhs, struct anydata &rhs)
{
	std::string st;
	//lhs>>st;
	getline(lhs, st);
	
	int i;
	std::stringstream ssi(st); ssi>>i;
	if (ssi.eof() == 1) {
		rhs = i;
		DEBUG(10, "got int");
		return lhs;
	}

	double d;
	std::stringstream ssd(st); ssd>>d;
	if (ssd.eof() == 1) {
		rhs = d;
		DEBUG(10, "got double");
		return lhs;
	}

	// vector is NOT to be checked here (but later)

	DEBUG(10, "got string or vector");
	rhs = st;
	return lhs;
}

bool check_vec(const std::string &s) {
	std::string tstr = trim(s, "\t");
    size_t ref1 = tstr.find("(",0), ref2 = tstr.find(":",0), ref3 = tstr.find(")",0);
    if (    ref1 != std::string::npos &&
            ref2 != std::string::npos &&
            ref3 != std::string::npos &&
            ref1 < ref2 && ref2 < ref3)
			return true;

    return false;
}

void anymap::loader(std::istream &is) {
    std::string st;
    clear();

    getline(is, st);
    while (st.find(__pp_init_str) == std::string::npos && !is.eof()) {
        DEBUG("get");
        getline(is, st);
    }

    getline(is, st);
    while (st.find(__pp_end_str) == std::string::npos && !is.eof()) {

        size_t eqpos = st.find("=");
        if (eqpos == std::string::npos) {
            DEBUG(st<<": malformed line");
            continue;
        }
        std::string st_key = trim(st.substr(0, eqpos), "\t ");
        std::string st_arg = trim(st.substr(eqpos+1, std::string::npos), "\t ");

        std::string clean_string = std::regex_replace(st_arg, std::regex("<br>"), "\n");

        if (st_key=="neutrinoPanData") {
            DEBUG("key: "<<st_key);
            DEBUG("arg: \n"<<st_arg);
        }
        // filling
        (*this)[st_key]=clean_string;
//            std::stringstream ss(clean_string);
//			ss>>(*this)[st_key];

        getline(is, st);
    }
    DEBUG("[anydata] read "<<size()<<" keys");
}

void anymap::dumper(std::ostream &os) {
    DEBUG("[anydata] Starting dump of "<<size()<<" elements");

    os<<__pp_init_str<<std::endl;

    // keys iterator
    std::map<std::string, anydata>::iterator itr;
    for (itr=begin(); itr != end(); ++itr) {
        DEBUG(5,"[anydata] Dumping "<<itr->first);

        // check if key was inserted by non-existent access
        // (strange std::map behaviour...)
        if (itr->second.ddescr != anydata::any_none) {
            std::string clean_string = std::regex_replace(itr->second.get_str(), std::regex("\\n"), "<br>");

            os<<itr->first<<" = "<<clean_string<<std::endl;
        }
    }
    os<<__pp_end_str<<std::endl;

    DEBUG("[anydata] Dumping ended");
}

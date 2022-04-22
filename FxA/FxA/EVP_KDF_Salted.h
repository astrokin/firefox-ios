// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#ifndef EVP_KDF_Salted_h
#define EVP_KDF_Salted_h

#include <stdio.h>

int
gen_evp_kdf_aes256cbc(const unsigned char *password,
                      const unsigned char *salt,
                      unsigned char key[],
                      unsigned char iv[]
                      );

#endif /* EVP_KDF_Salted_h */
